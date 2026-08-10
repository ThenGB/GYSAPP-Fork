import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:edge_tts/edge_tts.dart' as edge;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../components/components.dart';
import '../../../data/services/bible_tts_service.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../data/utilities/platform_utils.dart';
import '../../../router/router.dart';
import '../cubit/bible_state.dart';

@RoutePage()
class BibleAudioSettingView extends StatefulWidget {
  const BibleAudioSettingView({
    super.key,
    required this.initialState,
    required this.onSave,
  });

  final BibleState initialState;
  final Function(BibleState state) onSave;

  @override
  State<BibleAudioSettingView> createState() => _BibleAudioSettingViewState();
}

class _BibleAudioSettingViewState extends State<BibleAudioSettingView> {
  final BibleTtsService _tts = BibleTtsService();
  final Map<String, Map<String, String>> _nativeVoiceByLocale = {};

  late String _engine = widget.initialState.ttsEngine;
  late String _edgeVoice = widget.initialState.edgeVoice;
  late String _edgeRate = widget.initialState.edgeRate;
  late String _edgePitch = widget.initialState.edgePitch;
  late String _edgeVolume = widget.initialState.edgeVolume;
  late double _pitch = widget.initialState.pitchRate;
  late double _speed = widget.initialState.speedRate;

  List<edge.Voice> _edgeVoices = const [];
  List<Map<String, String>> _nativeVoices = const [];
  bool _voicesLoading = true;
  int _voiceLoadGeneration = 0;
  String? _testText;

  @override
  void initState() {
    super.initState();
    for (final entry in widget.initialState.voices.entries) {
      _nativeVoiceByLocale[entry.key] = entry.value.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }
    _loadVoicesForEngine();
  }

  Future<void> _loadVoicesForEngine() async {
    final generation = ++_voiceLoadGeneration;
    final requestedEngine = _engine;
    if (mounted) setState(() => _voicesLoading = true);
    try {
      if (requestedEngine == 'edge') {
        final edgeVoices = await BibleTtsService.fetchEdgeVoices();
        if (!mounted || generation != _voiceLoadGeneration) return;
        setState(() {
          _edgeVoices = edgeVoices;
          _voicesLoading = false;
        });
        return;
      }

      var native = <Map<String, String>>[];
      if (isTextToSpeechConfiguredForCurrentPlatform) {
        try {
          native = await BibleTtsService.fetchNativeVoices(
            tts: FlutterTts(),
          ).timeout(const Duration(seconds: 5));
        } catch (error) {
          log('Native voices fetch failed: $error', name: 'AudioSettings');
        }
      }
      if (!mounted || generation != _voiceLoadGeneration) return;
      setState(() {
        _nativeVoices = native;
        for (final locale in const ['id-ID', 'en-US', 'zh-CN']) {
          final resolved = BibleTtsService.resolveNativeVoice(
            voices: native,
            locale: locale,
            savedVoice: _nativeVoiceByLocale[locale],
          );
          if (resolved != null) _nativeVoiceByLocale[locale] = resolved;
        }
        _voicesLoading = false;
      });
    } catch (error) {
      log('Voice loading failed: $error', name: 'AudioSettings');
      if (mounted && generation == _voiceLoadGeneration) {
        setState(() => _voicesLoading = false);
      }
    }
  }

  Future<void> _changeEngine(String engine) async {
    if (_engine == engine) return;
    setState(() {
      _engine = engine;
      _voicesLoading = true;
    });
    await _tts.stop();
    await _loadVoicesForEngine();
  }

  List<Map<String, String>> _nativeVoicesFor(String locale) =>
      BibleTtsService.nativeVoicesForLocale(_nativeVoices, locale);

  Future<void> _testSpeak(String sample) async {
    final language = Localizations.localeOf(context).languageCode.toLowerCase();
    final sampleLocale = switch (language) {
      'id' => 'id-ID',
      'zh' => 'zh-CN',
      _ => 'en-US',
    };
    await _tts.stop();
    _tts.engine = _engine == 'native'
        ? BibleTtsEngine.native
        : BibleTtsEngine.edge;
    _tts.edgeVoice = _edgeVoice;
    _tts.edgeRate = _edgeRate;
    _tts.edgePitch = _edgePitch;
    _tts.edgeVolume = _edgeVolume;
    await _tts.configureNative(
      voice: BibleTtsService.resolveNativeVoice(
        voices: _nativeVoices,
        locale: sampleLocale,
        savedVoice: _nativeVoiceByLocale[sampleLocale],
      ),
      pitch: _pitch,
      speed: _speed,
    );
    final ok = await _tts.speak(sample);
    if (!ok) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(msg: 'tts_not_available'.tr());
    }
  }

  void _save() {
    widget.onSave(
      widget.initialState.copyWith(
        ttsEngine: _engine,
        edgeVoice: _edgeVoice,
        edgeRate: _edgeRate,
        edgePitch: _edgePitch,
        edgeVolume: _edgeVolume,
        pitchRate: _pitch,
        speedRate: _speed,
        voices: {
          ...widget.initialState.voices,
          ..._nativeVoiceByLocale,
        },
      ),
    );
    Fluttertoast.cancel();
    Fluttertoast.showToast(msg: 'Settings saved'.tr());
    router.maybePop();
  }

  @override
  void dispose() {
    _voiceLoadGeneration++;
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(_title(context))),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: Text('Save'.tr()),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionLabel('bible_tts_engine'.tr()),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  segments: [
                    const ButtonSegment(
                      value: 'edge',
                      icon: Icon(Icons.cloud_outlined, size: 18),
                      label: Text('Edge TTS'),
                    ),
                    ButtonSegment(
                      value: 'native',
                      icon: const Icon(Icons.phone_android_rounded, size: 18),
                      label: Text('bible_tts_native'.tr()),
                    ),
                  ],
                  selected: {_engine},
                  onSelectionChanged: (selection) =>
                      _changeEngine(selection.first),
                ),
                const SizedBox(height: 10),
                Text(
                  _engine == 'edge'
                      ? _edgeDescription(context)
                      : _nativeDescription(context),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            child: _engine == 'edge'
                ? _EdgeEngineSettings(
                    key: const ValueKey('edge-settings'),
                    loading: _voicesLoading,
                    voices: _edgeVoices,
                    selectedVoice: _edgeVoice,
                    rate: _edgeRate,
                    pitch: _edgePitch,
                    volume: _edgeVolume,
                    onVoice: (voice) => setState(() => _edgeVoice = voice),
                    onRate: (value) => setState(() => _edgeRate = value),
                    onPitch: (value) => setState(() => _edgePitch = value),
                    onVolume: (value) => setState(() => _edgeVolume = value),
                  )
                : _NativeEngineSettings(
                    key: const ValueKey('native-settings'),
                    loading: _voicesLoading,
                    nativeVoicesFor: _nativeVoicesFor,
                    selectedByLocale: _nativeVoiceByLocale,
                    pitch: _pitch,
                    speed: _speed,
                    onRetry: _loadVoicesForEngine,
                    onVoice: (locale, voice) => setState(
                      () => _nativeVoiceByLocale[locale] = voice,
                    ),
                    onPitch: (value) => setState(() => _pitch = value),
                    onSpeed: (value) => setState(() => _speed = value),
                  ),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionLabel(_testTitle(context)),
                const SizedBox(height: 8),
                TextField(
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'tts_test_hint'.tr(),
                  ),
                  onChanged: (value) => _testText = value,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: () => _testSpeak(
                      (_testText ?? '').trim().isEmpty
                          ? _defaultSample(context)
                          : _testText!.trim(),
                    ),
                    icon: const Icon(Icons.volume_up_rounded, size: 18),
                    label: Text('tts_test_button'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EdgeEngineSettings extends StatelessWidget {
  const _EdgeEngineSettings({
    super.key,
    required this.loading,
    required this.voices,
    required this.selectedVoice,
    required this.rate,
    required this.pitch,
    required this.volume,
    required this.onVoice,
    required this.onRate,
    required this.onPitch,
    required this.onVolume,
  });

  final bool loading;
  final List<edge.Voice> voices;
  final String selectedVoice;
  final String rate;
  final String pitch;
  final String volume;
  final ValueChanged<String> onVoice;
  final ValueChanged<String> onRate;
  final ValueChanged<String> onPitch;
  final ValueChanged<String> onVolume;

  @override
  Widget build(BuildContext context) {
    if (loading) return const _LoadingCard();
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionLabel(_edgeSettingsTitle(context)),
          const SizedBox(height: 10),
          if (voices.isEmpty)
            Text(
              'bible_edge_voices_offline'.tr(),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            )
          else
            DropdownButtonFormField<edge.Voice>(
              isExpanded: true,
              initialValue:
                  voices.where((v) => v.shortName == selectedVoice).firstOrNull ??
                  voices.first,
              decoration: InputDecoration(labelText: 'bible_edge_voice'.tr()),
              items: [
                for (final voice in voices)
                  DropdownMenuItem(
                    value: voice,
                    child: Text(
                      voice.shortName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (voice) {
                if (voice != null) onVoice(voice.shortName);
              },
            ),
          const SizedBox(height: 14),
          _PercentSlider(
            label: 'bible_voice_rate'.tr(),
            value: BibleTtsService.parseEdgePercent(rate).toDouble(),
            min: -50,
            max: 100,
            suffix: '%',
            onChanged: (value) => onRate(
              BibleTtsService.formatEdgePercent(value.round()),
            ),
          ),
          _PercentSlider(
            label: 'bible_voice_pitch'.tr(),
            value: BibleTtsService.parseEdgePitch(pitch).toDouble(),
            min: -50,
            max: 50,
            suffix: ' Hz',
            onChanged: (value) => onPitch(
              BibleTtsService.formatEdgePitch(value.round()),
            ),
          ),
          _PercentSlider(
            label: 'bible_voice_volume'.tr(),
            value: BibleTtsService.parseEdgePercent(volume).toDouble(),
            min: -50,
            max: 100,
            suffix: '%',
            onChanged: (value) => onVolume(
              BibleTtsService.formatEdgePercent(value.round()),
            ),
          ),
        ],
      ),
    );
  }
}

class _NativeEngineSettings extends StatelessWidget {
  const _NativeEngineSettings({
    super.key,
    required this.loading,
    required this.nativeVoicesFor,
    required this.selectedByLocale,
    required this.pitch,
    required this.speed,
    required this.onRetry,
    required this.onVoice,
    required this.onPitch,
    required this.onSpeed,
  });

  final bool loading;
  final List<Map<String, String>> Function(String locale) nativeVoicesFor;
  final Map<String, Map<String, String>> selectedByLocale;
  final double pitch;
  final double speed;
  final VoidCallback onRetry;
  final void Function(String locale, Map<String, String> voice) onVoice;
  final ValueChanged<double> onPitch;
  final ValueChanged<double> onSpeed;

  @override
  Widget build(BuildContext context) {
    final allVoicesAvailable = const ['id-ID', 'en-US', 'zh-CN']
        .any((locale) => nativeVoicesFor(locale).isNotEmpty);
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionLabel(_nativeSettingsTitle(context)),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: loading
                ? _NativeVoiceStatus(
                    key: const ValueKey('native-voices-loading'),
                    loading: true,
                    onRetry: onRetry,
                  )
                : !allVoicesAvailable
                ? _NativeVoiceStatus(
                    key: const ValueKey('native-voices-empty'),
                    loading: false,
                    onRetry: onRetry,
                  )
                : Column(
                    key: const ValueKey('native-voice-pickers'),
                    children: [
                      for (final entry in const [
                        ('id-ID', 'Indonesia'),
                        ('en-US', 'English'),
                        ('zh-CN', '中文'),
                      ]) ...[
                        _NativeVoicePicker(
                          label: entry.$2,
                          voices: nativeVoicesFor(entry.$1),
                          initialValue: selectedByLocale[entry.$1],
                          onChanged: (voice) => onVoice(entry.$1, voice),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
          ),
          if (loading || !allVoicesAvailable) const SizedBox(height: 14),
          _UnitSlider(
            label: 'tts_pitch_label'.tr(),
            value: pitch,
            min: 0.1,
            max: 2.0,
            display: pitch.toStringAsFixed(2),
            onChanged: onPitch,
          ),
          _UnitSlider(
            label: 'tts_speed_label'.tr(),
            value: speed,
            min: 0.1,
            max: 1.0,
            display: speed.toStringAsFixed(2),
            onChanged: onSpeed,
          ),
        ],
      ),
    );
  }
}

class _NativeVoiceStatus extends StatelessWidget {
  const _NativeVoiceStatus({
    super.key,
    required this.loading,
    required this.onRetry,
  });

  final bool loading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isIndonesian =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'id';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: context.appRadius(12),
      ),
      child: Row(
        children: [
          if (loading)
            const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              Icons.record_voice_over_outlined,
              size: 19,
              color: context.colorScheme.onSurfaceVariant,
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              loading
                  ? (isIndonesian
                        ? 'Memuat suara dari perangkat…'
                        : 'Loading device voices…')
                  : (isIndonesian
                        ? 'Suara perangkat belum tersedia. Pitch dan kecepatan tetap dapat diatur.'
                        : 'Device voices are not available yet. Pitch and speed remain configurable.'),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (!loading)
            IconButton(
              tooltip: isIndonesian ? 'Muat ulang suara' : 'Reload voices',
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
            ),
        ],
      ),
    );
  }
}

class _NativeVoicePicker extends StatelessWidget {
  const _NativeVoicePicker({
    required this.label,
    required this.voices,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final List<Map<String, String>> voices;
  final Map<String, String>? initialValue;
  final ValueChanged<Map<String, String>> onChanged;

  @override
  Widget build(BuildContext context) {
    if (voices.isEmpty) {
      return InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(
          'tts_not_available'.tr(),
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    Map<String, String> selected = voices.first;
    final requestedName = initialValue?['name'];
    final requestedIdentifier = initialValue?['identifier'];
    if (requestedName != null || requestedIdentifier != null) {
      selected = voices.firstWhere(
        (voice) =>
            (requestedName != null && voice['name'] == requestedName) ||
            (requestedIdentifier != null &&
                voice['identifier'] == requestedIdentifier),
        orElse: () => voices.first,
      );
    }
    return DropdownButtonFormField<Map<String, String>>(
      isExpanded: true,
      initialValue: selected,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final (index, voice) in voices.indexed)
          DropdownMenuItem(
            value: voice,
            child: Text(
              '$label · ${voice['name']?.toString().trim().isNotEmpty == true ? voice['name'] : 'Voice ${index + 1}'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (voice) {
        if (voice == null) return;
        onChanged(Map<String, String>.from(voice));
      },
    );
  }
}

class _PercentSlider extends StatelessWidget {
  const _PercentSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String suffix;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final display = '${value.round()}$suffix';
    return _UnitSlider(
      label: label,
      value: value,
      min: min,
      max: max,
      display: display,
      onChanged: onChanged,
    );
  }
}

class _UnitSlider extends StatelessWidget {
  const _UnitSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: context.textTheme.labelLarge)),
            Text(
              display,
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Slider.adaptive(
          value: value.clamp(min, max).toDouble(),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: context.appRadius(18),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.44),
        ),
      ),
      child: child,
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const _SettingsCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
  );
}

String _title(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
        ? 'Pengaturan Alkitab Suara'
        : 'Audio Bible Settings';

String _edgeDescription(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
        ? 'Suara neural berbasis jaringan. Pengaturan di bawah hanya berlaku untuk Edge TTS.'
        : 'Network neural voices. The controls below apply only to Edge TTS.';

String _nativeDescription(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
        ? 'Menggunakan mesin Text-to-Speech bawaan perangkat dan suara yang tersedia di sistem.'
        : 'Uses the device Text-to-Speech engine and voices installed on the system.';

String _edgeSettingsTitle(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
        ? 'Pengaturan Edge TTS'
        : 'Edge TTS Settings';

String _nativeSettingsTitle(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
        ? 'Pengaturan Mesin Bawaan'
        : 'Device Engine Settings';

String _testTitle(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
        ? 'Uji Suara'
        : 'Test Voice';

String _defaultSample(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
        ? 'Halo, selamat datang di Alkitab.'
        : 'Hello, welcome to the Bible.';
