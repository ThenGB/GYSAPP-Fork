import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../domain/domain.dart';
import '../data.dart';
import 'windows_midi_player.dart';

class SongHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer player;
  final WindowsMidiPlayer windowsMidiPlayer = WindowsMidiPlayer();
  Function()? onNext;
  final Debouncer debouncer = Debouncer(Duration(milliseconds: 500));

  void initNextFunction({required Function() nextFunction}) {
    onNext = nextFunction;
  }

  SongHandler({required this.player}) {
    player.eventStream.map(_transformEvent).listen((event) {
      playbackState.add(event);
    });

    player.onPositionChanged.listen((event) {
      playbackState.add(
        playbackState.value.copyWith(
          updatePosition: event,
        ),
      );
    });

    player.onPlayerStateChanged
        .map(
      (event) =>
          playbackState.value.copyWith(playing: event == PlayerState.playing),
    )
        .listen((event) {
      playbackState.add(event);

      // Tambahan: fallback jika "complete" tidak muncul di eventStream
      if (player.state == PlayerState.completed) {
        debouncer.run(() {
          if (onNext == null) log('onNext not set!');
          onNext?.call();
        });
      }
    });
  }

  void clearQueue() {
    if (queue.value.isNotEmpty) {
      final newList = [...queue.value];
      newList.removeLast();
      queue.add(newList); // perbaikan: update Notifier dengan benar
    }
  }

  @override
  Future<void> play() async {
    if (windowsMidiPlayer.hasSource) {
      await windowsMidiPlayer.play();
      playbackState.add(playbackState.value.copyWith(playing: true));
      return;
    }
    // perbaikan: hindari player.source! yang bisa null
    await player.resume();
  }

  Future setSource(Source source, Song song) async {
    try {
      await windowsMidiPlayer.stop();
      await player.setSource(source);

      String mediaItemId = song.title ?? '';

      // perbaikan: ganti UniqueKey() dengan ID unik tanpa import tambahan
      if (mediaItemId.isEmpty) {
        mediaItemId = 'id_${DateTime.now().microsecondsSinceEpoch}';
      }

      if (source is AssetSource) {
        mediaItemId = source.path;
      } else if (source is DeviceFileSource) {
        mediaItemId = source.path;
      }

      final dur = await player.getDuration();

      mediaItem.add(
        MediaItem(
          id: mediaItemId,
          title: song.title ?? 'Unknown',
          duration: dur ?? Duration.zero,
        ),
      );
    } catch (e) {
      log(e.toString());
    }
  }

  Future setWindowsMidiAsset(String assetPath, Song song) async {
    try {
      await player.stop();
      await windowsMidiPlayer.setAsset(assetPath);

      mediaItem.add(
        MediaItem(
          id: assetPath,
          title: song.title ?? 'Unknown',
          duration: Duration.zero,
        ),
      );
      playbackState.add(
        playbackState.value.copyWith(
          controls: const [MediaControl.play, MediaControl.stop],
          processingState: AudioProcessingState.ready,
          playing: false,
        ),
      );
    } catch (e) {
      log('Windows MIDI source failed: $e', name: 'SongHandler');
    }
  }

  @override
  Future<void> pause() async {
    if (windowsMidiPlayer.hasSource) {
      await windowsMidiPlayer.pause();
      playbackState.add(playbackState.value.copyWith(playing: false));
      return;
    }
    await player.pause();
  }

  @override
  Future<void> stop() async {
    if (windowsMidiPlayer.hasSource) {
      await windowsMidiPlayer.stop();
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.idle,
          playing: false,
        ),
      );
      return;
    }
    await player.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await player.seek(position).timeout(const Duration(seconds: 1));
    } catch (e) {
      log('seek timeout: $e');
    }
  }

  PlaybackState _transformEvent(AudioEvent event) {
    log(player.state.name);

    if (event.eventType == AudioEventType.complete) {
      debouncer.run(() {
        if (onNext == null) log('onNext not set!');
        onNext?.call();
      });
    }

    return PlaybackState(
      controls: [
        if (player.state == PlayerState.playing)
          MediaControl.pause
        else
          MediaControl.play,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
      },
      processingState: const {
            PlayerState.playing: AudioProcessingState.ready,
            PlayerState.stopped: AudioProcessingState.idle,
            PlayerState.paused: AudioProcessingState.ready,
            PlayerState.completed: AudioProcessingState.completed,
            PlayerState.disposed: AudioProcessingState.idle,
          }[player.state] ??
          AudioProcessingState.idle, // perbaikan: fallback
      playing: player.state == PlayerState.playing,
      speed: 1,
      queueIndex: 0,
    );
  }
}
