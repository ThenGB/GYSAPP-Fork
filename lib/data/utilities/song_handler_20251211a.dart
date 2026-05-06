import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../domain/domain.dart';
import '../data.dart';

class SongHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer player;
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
    });
  }

  void clearQueue() {
    if (queue.value.isNotEmpty) {
      queue.value.removeLast();
    }
  }

  @override
  Future<void> play() async {
    await player.play(player.source!);
  }

  Future setSource(Source source, Song song) async {
    try {
      await player.setSource(source);
      String mediaItemId = song.title ?? '';
      if (source is AssetSource) {
        mediaItemId = source.path;
      } else if (source is DeviceFileSource) {
        mediaItemId = source.path;
      }

      mediaItem.add(
        MediaItem(
          id: mediaItemId,
          title: song.title ?? 'Unknown',
          duration: await player.getDuration(),
        ),
      );
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Future<void> pause() async {
    await player.pause();
    // var currentPosition = await player.getCurrentPosition();
    // await Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Future<void> stop() async {
    await player.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    // playbackState.add(
    //   playbackState.value.copyWith(
    //     bufferedPosition: position,
    //   ),
    // );
    await player.seek(position);
  }

  PlaybackState _transformEvent(AudioEvent event) {
    log(player.state.name);
    if (event.eventType == AudioEventType.complete) {
      debouncer.run(() => onNext?.call());
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
      // androidCompactActionIndices: const [0, 1],
      processingState: const {
        PlayerState.playing: AudioProcessingState.ready,
        PlayerState.stopped: AudioProcessingState.idle,
        PlayerState.paused: AudioProcessingState.ready,
        PlayerState.completed: AudioProcessingState.completed,
        PlayerState.disposed: AudioProcessingState.idle,
      }[player.state]!,
      playing: player.state == PlayerState.playing,
      // updatePosition: event.position ??
      //     event.duration ??
      //     playbackState.value.updatePosition,
      // bufferedPosition: event.position ?? event.duration ?? Duration.zero,
      speed: 1,
      queueIndex: 0,
    );
  }
}
