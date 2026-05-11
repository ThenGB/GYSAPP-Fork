import 'package:church/domain/entity/song/song_entity.dart';
import 'package:church/presentations/song/cubit/song_playlist.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const kr001 = Song(code: 'KR', number: '001', title: 'One');
  const kr002 = Song(code: 'KR', number: '002', title: 'Two');
  const kr003 = Song(code: 'KR', number: '003', title: 'Three');
  const mdr001 = Song(code: 'MDR', number: '001', title: 'MDR One');
  const books = [
    SongBook(code: 'KR', songs: [kr001, kr002, kr003]),
    SongBook(code: 'MDR', songs: [mdr001]),
  ];

  group('SongPlaybackQueue', () {
    test('cycles auto-next modes in the same order as gyschordweb', () {
      expect(
        SongPlaylistAutoNextMode.cycle(
          SongPlaylistAutoNextMode.off,
          hasUsableShufflePlaylist: true,
        ),
        SongPlaylistAutoNextMode.one,
      );
      expect(
        SongPlaylistAutoNextMode.cycle(
          SongPlaylistAutoNextMode.one,
          hasUsableShufflePlaylist: true,
        ),
        SongPlaylistAutoNextMode.number,
      );
      expect(
        SongPlaylistAutoNextMode.cycle(
          SongPlaylistAutoNextMode.number,
          hasUsableShufflePlaylist: true,
        ),
        SongPlaylistAutoNextMode.playlist,
      );
      expect(
        SongPlaylistAutoNextMode.cycle(
          SongPlaylistAutoNextMode.playlist,
          hasUsableShufflePlaylist: true,
        ),
        SongPlaylistAutoNextMode.shuffleAll,
      );
      expect(
        SongPlaylistAutoNextMode.cycle(
          SongPlaylistAutoNextMode.shuffleAll,
          hasUsableShufflePlaylist: true,
        ),
        SongPlaylistAutoNextMode.shufflePlaylist,
      );
      expect(
        SongPlaylistAutoNextMode.cycle(
          SongPlaylistAutoNextMode.shufflePlaylist,
          hasUsableShufflePlaylist: true,
        ),
        SongPlaylistAutoNextMode.off,
      );
    });

    test('skips shuffle-playlist when no usable playlist is active', () {
      expect(
        SongPlaylistAutoNextMode.cycle(
          SongPlaylistAutoNextMode.shuffleAll,
          hasUsableShufflePlaylist: false,
        ),
        SongPlaylistAutoNextMode.off,
      );
    });

    test('resolves the next song from the visible song list by default', () {
      final queue = SongPlaybackQueue.resolve(
        books: books,
        currentSongs: const [kr001, kr002, kr003],
        currentSong: kr002,
        playlists: const [],
        activePlaylistId: null,
        autoNextMode: SongPlaylistAutoNextMode.off,
        shuffleIndex: const [],
      );

      expect(queue.currentSong, kr002);
      expect(queue.nextSong, kr003);
    });

    test('manual navigation wraps around the visible list', () {
      final atEnd = SongPlaybackQueue.resolve(
        books: books,
        currentSongs: const [kr001, kr002, kr003],
        currentSong: kr003,
        playlists: const [],
        activePlaylistId: null,
        autoNextMode: SongPlaylistAutoNextMode.off,
        shuffleIndex: const [],
      );
      final atStart = SongPlaybackQueue.resolve(
        books: books,
        currentSongs: const [kr001, kr002, kr003],
        currentSong: kr001,
        playlists: const [],
        activePlaylistId: null,
        autoNextMode: SongPlaylistAutoNextMode.off,
        shuffleIndex: const [],
      );

      expect(atEnd.manualNextSong, kr001);
      expect(atStart.manualPreviousSong, kr003);
    });

    test('resolves active playlist order across books', () {
      final playlist = SongPlaylist(
        id: 'pl-1',
        name: 'Ibadah',
        songs: [
          SongPlaylistItem.fromSong(kr002),
          SongPlaylistItem.fromSong(mdr001),
        ],
      );

      final queue = SongPlaybackQueue.resolve(
        books: books,
        currentSongs: const [kr001, kr002, kr003],
        currentSong: kr002,
        playlists: [playlist],
        activePlaylistId: 'pl-1',
        autoNextMode: SongPlaylistAutoNextMode.playlist,
        shuffleIndex: const [],
      );

      expect(queue.nextSong, mdr001);
      expect(queue.nextIndexInBook, 0);
      expect(queue.nextBookCode, 'MDR');
    });

    test('loops sequential playlist to the first song at the end', () {
      final playlist = SongPlaylist(
        id: 'pl-1',
        name: 'Ibadah',
        songs: [
          SongPlaylistItem.fromSong(kr002),
          SongPlaylistItem.fromSong(mdr001),
        ],
      );

      final queue = SongPlaybackQueue.resolve(
        books: books,
        currentSongs: const [mdr001],
        currentSong: mdr001,
        playlists: [playlist],
        activePlaylistId: 'pl-1',
        autoNextMode: SongPlaylistAutoNextMode.playlist,
        shuffleIndex: const [],
      );

      expect(queue.nextSong, kr002);
      expect(queue.nextBookCode, 'KR');
      expect(queue.nextIndexInBook, 1);
    });

    test('number mode auto-next wraps like gyschordweb', () {
      final queue = SongPlaybackQueue.resolve(
        books: books,
        currentSongs: const [kr001, kr002, kr003],
        currentSong: kr003,
        playlists: const [],
        activePlaylistId: null,
        autoNextMode: SongPlaylistAutoNextMode.number,
        shuffleIndex: const [],
      );

      expect(queue.nextSong, kr001);
    });

    test('uses deterministic shuffle order for shuffle-all playback', () {
      final queue = SongPlaybackQueue.resolve(
        books: books,
        currentSongs: const [kr001, kr002, kr003],
        currentSong: kr001,
        playlists: const [],
        activePlaylistId: null,
        autoNextMode: SongPlaylistAutoNextMode.shuffleAll,
        shuffleIndex: const [2, 0, 1],
      );

      expect(queue.nextSong, kr002);
    });

    test('loops shuffle-all order when it reaches the last item', () {
      final queue = SongPlaybackQueue.resolve(
        books: books,
        currentSongs: const [kr001, kr002, kr003],
        currentSong: kr002,
        playlists: const [],
        activePlaylistId: null,
        autoNextMode: SongPlaylistAutoNextMode.shuffleAll,
        shuffleIndex: const [2, 0, 1],
      );

      expect(queue.nextSong, kr003);
    });

    test('uses deterministic shuffle order within active playlist', () {
      final playlist = SongPlaylist(
        id: 'pl-1',
        name: 'Ibadah',
        songs: [
          SongPlaylistItem.fromSong(kr001),
          SongPlaylistItem.fromSong(kr002),
          SongPlaylistItem.fromSong(kr003),
        ],
      );

      final queue = SongPlaybackQueue.resolve(
        books: books,
        currentSongs: const [kr001, kr002, kr003],
        currentSong: kr001,
        playlists: [playlist],
        activePlaylistId: 'pl-1',
        autoNextMode: SongPlaylistAutoNextMode.shufflePlaylist,
        shuffleIndex: const [2, 0, 1],
      );

      expect(queue.nextSong, kr002);
    });

    test('preload songs include both queue neighbors with wrapping', () {
      final queue = SongPlaybackQueue.resolve(
        books: books,
        currentSongs: const [kr001, kr002, kr003],
        currentSong: kr001,
        playlists: const [],
        activePlaylistId: null,
        autoNextMode: SongPlaylistAutoNextMode.off,
        shuffleIndex: const [],
      );

      expect(queue.preloadSongs(count: 1), [kr002, kr003]);
    });
  });
}
