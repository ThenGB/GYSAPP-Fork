import 'package:collection/collection.dart';

import '../../../domain/entity/song/song_entity.dart';

class SongPlaylistAutoNextMode {
  static const off = 'off';
  static const one = 'one';
  static const number = 'number';
  static const playlist = 'playlist';
  static const shuffleAll = 'shuffle-all';
  static const shufflePlaylist = 'shuffle-playlist';

  static const values = [
    off,
    one,
    number,
    playlist,
    shuffleAll,
    shufflePlaylist,
  ];

  static String normalize(String mode) {
    return values.contains(mode) ? mode : off;
  }

  static String cycle(
    String current, {
    required bool hasUsableShufflePlaylist,
  }) {
    return switch (normalize(current)) {
      off => one,
      one => number,
      number => playlist,
      playlist => shuffleAll,
      shuffleAll => hasUsableShufflePlaylist ? shufflePlaylist : off,
      _ => off,
    };
  }
}

class SongPlaylistItem {
  final String code;
  final String number;
  final String title;
  final DateTime addedAt;

  const SongPlaylistItem({
    required this.code,
    required this.number,
    required this.title,
    required this.addedAt,
  });

  factory SongPlaylistItem.fromSong(Song song, {DateTime? addedAt}) {
    return SongPlaylistItem(
      code: song.code ?? '',
      number: song.number ?? '',
      title: song.title ?? '',
      addedAt: addedAt ?? DateTime.now(),
    );
  }

  factory SongPlaylistItem.fromJson(Map<String, dynamic> json) {
    return SongPlaylistItem(
      code: json['code'] as String? ?? '',
      number: json['number'] as String? ?? '',
      title: json['title'] as String? ?? '',
      addedAt:
          DateTime.tryParse(json['addedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'number': number,
      'title': title,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  bool matches(Song song) {
    return song.code == code && song.number == number;
  }
}

class SongPlaylist {
  final String id;
  final String name;
  final List<SongPlaylistItem> songs;
  final DateTime createdAt;

  SongPlaylist({
    required this.id,
    required this.name,
    required List<SongPlaylistItem> songs,
    DateTime? createdAt,
  }) : songs = List.unmodifiable(songs),
       createdAt = createdAt ?? DateTime.now();

  factory SongPlaylist.fromJson(Map<String, dynamic> json) {
    return SongPlaylist(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Playlist',
      songs:
          (json['songs'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(SongPlaylistItem.fromJson)
              .toList() ??
          const [],
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'songs': songs.map((song) => song.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  SongPlaylist copyWith({
    String? id,
    String? name,
    List<SongPlaylistItem>? songs,
    DateTime? createdAt,
  }) {
    return SongPlaylist(
      id: id ?? this.id,
      name: name ?? this.name,
      songs: songs ?? this.songs,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SongPlaybackQueue {
  final List<Song> songs;
  final int currentQueueIndex;
  final String autoNextMode;
  final List<SongBook> books;

  const SongPlaybackQueue({
    required this.songs,
    required this.currentQueueIndex,
    required this.autoNextMode,
    required this.books,
  });

  factory SongPlaybackQueue.resolve({
    required List<SongBook> books,
    required List<Song> currentSongs,
    required Song? currentSong,
    required List<SongPlaylist> playlists,
    required String? activePlaylistId,
    required String autoNextMode,
    required List<int> shuffleIndex,
  }) {
    final normalizedMode = SongPlaylistAutoNextMode.normalize(autoNextMode);
    final allSongs = books.expand((book) => book.songs).toList();
    final activePlaylist = playlists
        .where((playlist) => playlist.id == activePlaylistId)
        .firstOrNull;

    final List<Song> queue = switch (normalizedMode) {
      SongPlaylistAutoNextMode.playlist => _resolvePlaylistSongs(
        activePlaylist,
        allSongs,
      ),
      SongPlaylistAutoNextMode.shufflePlaylist => _resolveShuffledSongs(
        _resolvePlaylistSongs(activePlaylist, allSongs),
        shuffleIndex,
      ),
      SongPlaylistAutoNextMode.shuffleAll => _resolveShuffledSongs(
        currentSongs,
        shuffleIndex,
      ),
      _ => currentSongs,
    };
    final fallbackQueue = queue.isEmpty ? currentSongs : queue;
    final currentIndex = _indexOfSong(fallbackQueue, currentSong);

    return SongPlaybackQueue(
      songs: List.unmodifiable(fallbackQueue),
      currentQueueIndex: currentIndex < 0 ? 0 : currentIndex,
      autoNextMode: normalizedMode,
      books: books,
    );
  }

  Song? get currentSong {
    if (songs.isEmpty ||
        currentQueueIndex < 0 ||
        currentQueueIndex >= songs.length) {
      return null;
    }
    return songs[currentQueueIndex];
  }

  Song? get nextSong {
    if (songs.isEmpty) return null;
    if (autoNextMode == SongPlaylistAutoNextMode.one) return currentSong;
    if (currentQueueIndex < songs.length - 1) {
      return songs[currentQueueIndex + 1];
    }
    if (_autoNextWraps) {
      return songs.first;
    }
    return null;
  }

  Song? get previousSong {
    if (songs.isEmpty || currentQueueIndex <= 0) return null;
    return songs[currentQueueIndex - 1];
  }

  Song? get manualNextSong {
    if (songs.isEmpty) return null;
    if (songs.length == 1) return currentSong;
    if (currentQueueIndex < songs.length - 1) {
      return songs[currentQueueIndex + 1];
    }
    return songs.first;
  }

  Song? get manualPreviousSong {
    if (songs.isEmpty) return null;
    if (songs.length == 1) return currentSong;
    if (currentQueueIndex > 0) {
      return songs[currentQueueIndex - 1];
    }
    return songs.last;
  }

  List<Song> preloadSongs({int count = 1}) {
    if (songs.length <= 1 || count <= 0) return const [];
    final preload = <Song>[];
    final seen = <String>{};
    void addSong(Song song) {
      final key = '${song.code ?? ''}:${song.number ?? ''}';
      if (currentSong != null && _sameSong(song, currentSong!)) return;
      if (seen.add(key)) preload.add(song);
    }

    for (var step = 1; step <= count; step++) {
      addSong(songs[(currentQueueIndex + step) % songs.length]);
      addSong(songs[(currentQueueIndex - step) % songs.length]);
    }
    return List.unmodifiable(preload);
  }

  bool get _autoNextWraps =>
      autoNextMode == SongPlaylistAutoNextMode.number ||
      autoNextMode == SongPlaylistAutoNextMode.playlist ||
      autoNextMode == SongPlaylistAutoNextMode.shuffleAll ||
      autoNextMode == SongPlaylistAutoNextMode.shufflePlaylist;

  String? get nextBookCode => nextSong?.code;

  int? get nextIndexInBook {
    final song = nextSong;
    if (song == null) return null;
    final book = books.where((book) => book.code == song.code).firstOrNull;
    if (book == null) return null;
    final index = _indexOfSong(book.songs, song);
    return index < 0 ? null : index;
  }

  static List<Song> _resolvePlaylistSongs(
    SongPlaylist? playlist,
    List<Song> allSongs,
  ) {
    if (playlist == null) return const [];
    return playlist.songs
        .map((item) => allSongs.where((song) => item.matches(song)).firstOrNull)
        .whereType<Song>()
        .toList();
  }

  static List<Song> _resolveShuffledSongs(
    List<Song> songs,
    List<int> shuffleIndex,
  ) {
    if (songs.isEmpty) return const [];
    if (shuffleIndex.length != songs.length) return songs;
    final result = <Song>[];
    for (final index in shuffleIndex) {
      if (index < 0 || index >= songs.length) return songs;
      result.add(songs[index]);
    }
    return result;
  }

  static int _indexOfSong(List<Song> songs, Song? target) {
    if (target == null) return -1;
    return songs.indexWhere((song) => _sameSong(song, target));
  }

  static bool _sameSong(Song a, Song b) {
    return a.code == b.code && a.number == b.number;
  }
}
