class WindowsMidiPlayer {
  bool get hasSource => false;
  bool get isReady => false;

  Future<bool> setAsset(String assetPath) async => false;

  Future<bool> play() async => false;

  Future<void> pause() async {}

  Future<void> stop() async {}

  String? getMode() => null;

  int? getPositionMs() => null;

  int? getLengthMs() => null;
}
