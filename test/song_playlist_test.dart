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
    test(
      'preloads current neighbors from the visible song list by default',
      () {
        final queue = SongPlaybackQueue.resolve(
          books: books,
          currentSongs: const [kr001, kr002, kr003],
          currentSong: kr002,
          playlists: const [],
          activePlaylistId: null,
          autoNextMode: SongPlaylistAutoNextMode.off,
          shuffleIndex: const [],
        );

        expect(queue.getPreloadSongs(1), [kr002, kr001, kr003]);
        expect(queue.nextSong, kr003);
      },
    );

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

      expect(queue.getPreloadSongs(1), [kr002, mdr001]);
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

    test('uses deterministic shuffle order for shuffle-all preload', () {
      final queue = SongPlaybackQueue.resolve(
        books: books,
        currentSongs: const [kr001, kr002, kr003],
        currentSong: kr001,
        playlists: const [],
        activePlaylistId: null,
        autoNextMode: SongPlaylistAutoNextMode.shuffleAll,
        shuffleIndex: const [2, 0, 1],
      );

      expect(queue.getPreloadSongs(1), [kr001, kr003, kr002]);
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

      expect(queue.getPreloadSongs(1), [kr001, kr003, kr002]);
      expect(queue.nextSong, kr002);
    });
  });
}
