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
  List<Map> _nativeVoices = const [];
  bool _voicesLoading = true;
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
    if (mounted) setState(() => _voicesLoading = true);
    try {
      if (_engine == 'edge') {
        final edgeVoices = await BibleTtsService.fetchEdgeVoices();
        if (!mounted) return;
        setState(() {
          _edgeVoices = edgeVoices;
          _voicesLoading = false;
        });
        return;
      }

      var native = <Map>[];
      if (isTextToSpeechConfiguredForCurrentPlatform) {
        try {
          final tts = FlutterTts();
          native = (await tts.getVoices as List<Object?>)
              .cast<Map>()
              .map(
                (voice) => voice.map(
                  (key, value) => MapEntry(
                    key.toString(),
                    value?.toString() ?? '',
                  ),
                ),
              )
              .toList();
        } catch (error) {
          log('Native voices fetch failed: $error', name: 'AudioSettings');
        }
      }
      if (!mounted) return;
      setState(() {
        _nativeVoices = native;
        _voicesLoading = false;
      });
    } catch (error) {
      log('Voice loading failed: $error', name: 'AudioSettings');
      if (mounted) setState(() => _voicesLoading = false);
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

  List<Map> _nativeVoicesFor(String locale) =>
      _nativeVoices.where((voice) => voice['locale'] == locale).toList();

  Future<void> _testSpeak(String sample) async {
    await _tts.stop();
    _tts.engine = _engine == 'native'
        ? BibleTtsEngine.native
        : BibleTtsEngine.edge;
    _tts.edgeVoice = _edgeVoice;
    _tts.edgeRate = _edgeRate;
    _tts.edgePitch = _edgePitch;
    _tts.edgeVolume = _edgeVolume;
    await _tts.configureNative(pitch: _pitch, speed: _speed);
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
  }

  @override
  void dispose() {
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
    required this.onVoice,
    required this.onPitch,
    required this.onSpeed,
  });

  final bool loading;
  final List<Map> Function(String locale) nativeVoicesFor;
  final Map<String, Map<String, String>> selectedByLocale;
  final double pitch;
  final double speed;
  final void Function(String locale, Map<String, String> voice) onVoice;
  final ValueChanged<double> onPitch;
  final ValueChanged<double> onSpeed;

  @override
  Widget build(BuildContext context) {
    if (loading) return const _LoadingCard();
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionLabel(_nativeSettingsTitle(context)),
          const SizedBox(height: 10),
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

class _NativeVoicePicker extends StatelessWidget {
  const _NativeVoicePicker({
    required this.label,
    required this.voices,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final List<Map> voices;
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

    Map selected = voices.first;
    final requestedName = initialValue?['name'];
    if (requestedName != null) {
      selected = voices.firstWhere(
        (voice) => voice['name'] == requestedName,
        orElse: () => voices.first,
      );
    }
    return DropdownButtonFormField<Map>(
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
        onChanged(
          voice.map(
            (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
          ),
        );
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
          value: value.clamp(min, max),
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
