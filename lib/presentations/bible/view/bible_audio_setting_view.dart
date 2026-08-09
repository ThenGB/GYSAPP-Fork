import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:edge_tts/edge_tts.dart' as edge;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../components/components.dart';
import '../../../data/data.dart';
import '../../../data/services/bible_tts_service.dart';
import '../cubit/bible_cubit.dart';
import '../cubit/bible_state.dart';

@RoutePage()
class BibleAudioSettingView extends StatefulWidget {
  final BibleState initialState;
  final Function(
    BibleState state,
  ) onSave;
  const BibleAudioSettingView({
    super.key,
    required this.initialState,
    required this.onSave,
  });

  @override
  State<BibleAudioSettingView> createState() => _BibleAudioSettingViewState();
}

class _BibleAudioSettingViewState extends State<BibleAudioSettingView> {
  final BibleTtsService _tts = BibleTtsService();

  late String _engine = widget.initialState.ttsEngine;
  late String _edgeVoice = widget.initialState.edgeVoice;
  late String _edgeRate = widget.initialState.edgeRate;
  late String _edgePitch = widget.initialState.edgePitch;
  late String _edgeVolume = widget.initialState.edgeVolume;
  late double _pitch = widget.initialState.pitchRate;
  late double _speed = widget.initialState.speedRate;

  List<edge.Voice> _edgeVoices = [];
  List<Map> _nativeVoices = [];
  bool _voicesLoading = true;
  String? _testText;

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    setState(() => _voicesLoading = true);
    // Edge voice list (network; empty when offline).
    final edgeVoices = await BibleTtsService.fetchEdgeVoices();
    // Native device voices (when supported).
    List<Map> native = [];
    final nativeTts = isTextToSpeechConfiguredForCurrentPlatform
        ? FlutterTts()
        : null;
    if (nativeTts != null) {
      try {
        native = (await nativeTts.getVoices as List<Object?>)
            .cast<Map>()
            .toList()
            .map(
              (e) => e.map(
                (key, value) => MapEntry(key.toString(), value.toString()),
              ),
            )
            .toList();
      } catch (e) {
        log('Native voices fetch failed: $e', name: 'AudioSettings');
      }
    }
    if (!mounted) return;
    setState(() {
      _edgeVoices = edgeVoices;
      _nativeVoices = native;
      _voicesLoading = false;
    });
  }

  List<Map> _nativeVoicesFor(String locale) {
    return _nativeVoices
        .where((e) => e['locale'] == locale)
        .toList();
  }

  Future<void> _testSpeak(String sample) async {
    await _tts.stop();
    _tts.engine = _engine == 'native'
        ? BibleTtsEngine.native
        : BibleTtsEngine.edge;
    _tts.edgeVoice = _edgeVoice;
    _tts.edgeRate = _edgeRate;
    _tts.edgePitch = _edgePitch;
    _tts.edgeVolume = _edgeVolume;
    await _tts.configureNative(
      pitch: _pitch,
      speed: _speed,
    );
    final ok = await _tts.speak(sample);
    if (!ok) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(msg: 'tts_not_available'.tr());
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(color: colors.outlineVariant),
        ),
        title: Text('Audio Bible Config'.tr()),
      ),
      bottomNavigationBar: BottomAppBar(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
          ),
          onPressed: () => widget.onSave(
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
          ),
          child: Text('Save'.tr()),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Engine ───────────────────────────────────────────────────
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label('bible_tts_engine'.tr()),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'edge',
                        icon: const Icon(Icons.cloud_outlined, size: 18),
                        label: Text('Edge TTS'),
                      ),
                      ButtonSegment(
                        value: 'native',
                        icon: const Icon(
                          Icons.phonelink_ring_outlined,
                          size: 18,
                        ),
                        label: Text('bible_tts_native'.tr()),
                      ),
                    ],
                    selected: {_engine},
                    onSelectionChanged: (s) =>
                        setState(() => _engine = s.first),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'bible_tts_fallback_note'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.primary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Edge voices ──────────────────────────────────────────────
            if (_engine == 'edge') ...[
              _Card(
                child: _voicesLoading
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('bible_edge_voice'.tr()),
                          const SizedBox(height: 4),
                          if (_edgeVoices.isEmpty)
                            Text(
                              'bible_edge_voices_offline'.tr(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            )
                          else ...[
                            _VoiceDropdown<edge.Voice>(
                              value: _edgeVoices
                                      .where((v) => v.shortName == _edgeVoice)
                                      .firstOrNull ??
                                  _edgeVoices.first,
                              items: _edgeVoices,
                              labelOf: (v) => v.shortName,
                              onChanged: (v) =>
                                  setState(() => _edgeVoice = v.shortName),
                            ),
                            const SizedBox(height: 12),
                            _Label('bible_voice_rate'.tr()),
                            _TextValueSlider(
                              value: BibleTtsService.parseEdgePercent(
                                _edgeRate,
                              ).toDouble(),
                              min: -50,
                              max: 100,
                              display:
                                  '${BibleTtsService.parseEdgePercent(_edgeRate)}%',
                              onChanged: (p) => setState(
                                () => _edgeRate = BibleTtsService
                                    .formatEdgePercent(p.round()),
                              ),
                            ),
                            _Label('bible_voice_pitch'.tr()),
                            _TextValueSlider(
                              value: BibleTtsService.parseEdgePitch(
                                _edgePitch,
                              ).toDouble(),
                              min: -50,
                              max: 50,
                              display:
                                  '${BibleTtsService.parseEdgePitch(_edgePitch)}Hz',
                              onChanged: (p) => setState(
                                () => _edgePitch = BibleTtsService
                                    .formatEdgePitch(p.round()),
                              ),
                            ),
                            _Label('bible_voice_volume'.tr()),
                            _TextValueSlider(
                              value: BibleTtsService.parseEdgePercent(
                                _edgeVolume,
                              ).toDouble(),
                              min: -50,
                              max: 100,
                              display:
                                  '${BibleTtsService.parseEdgePercent(_edgeVolume)}%',
                              onChanged: (p) => setState(
                                () => _edgeVolume = BibleTtsService
                                    .formatEdgePercent(p.round()),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
              const SizedBox(height: 12),
            ],

            // ── Native voice (per locale) ────────────────────────────────
            if (_engine == 'native') ...[
              _Card(
                child: _voicesLoading
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('bible_native_voice'.tr()),
                          const SizedBox(height: 4),
                          if (_nativeVoices.isEmpty)
                            Text(
                              'tts_not_available'.tr(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            )
                          else
                            for (final (lang, label) in [
                              ('id-ID', 'tts_bahasa_placeholder'.tr()),
                              ('en-US', 'tts_english_placeholder'.tr()),
                              ('zh-CN', 'tts_chinese_placeholder'.tr()),
                            ]) ...[                              _NativeVoiceRow(
                                label: label,
                                voices: _nativeVoicesFor(lang),
                                initialValue: _nativeVoiceByLocale[lang],
                                onChanged: (v) {
                                  setState(() {
                                    _nativeVoiceByLocale[lang] = v;
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                        ],
                      ),
              ),
              const SizedBox(height: 12),
            ],

            // ── Pitch / speed (shared) ───────────────────────────────────
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label('tts_pitch_label'.tr()),
                  Slider.adaptive(
                    value: _pitch,
                    min: 0.1,
                    max: 2.0,
                    onChanged: (v) => setState(() => _pitch = v),
                  ),
                  _Label('tts_speed_label'.tr()),
                  Slider.adaptive(
                    value: _speed,
                    min: 0.1,
                    max: 1.0,
                    onChanged: (v) => setState(() => _speed = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Test ─────────────────────────────────────────────────────
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label('tts_test_label'.tr()),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'tts_test_hint'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: context.appRadius(10),
                      ),
                    ),
                    onChanged: (v) => _testText = v,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonalIcon(
                      onPressed: () => _testSpeak(
                        (_testText ?? '').trim().isEmpty
                            ? 'Halo, selamat datang di Alkitab.'
                            : _testText!,
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
      ),
    );
  }

  // ─── helpers ───────────────────────────────────────────────────────────
  final Map<String, Map<String, String>> _nativeVoiceByLocale = {};
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: context.appRadius(14),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: child,
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: context.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _VoiceDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  const _VoiceDropdown({
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      isExpanded: true,
      initialValue: value,
      items: [
        for (final item in items)
          DropdownMenuItem(value: item, child: Text(labelOf(item))),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      decoration: InputDecoration(
        isDense: true,
        border: OutlineInputBorder(borderRadius: context.appRadius(10)),
      ),
    );
  }
}

class _TextValueSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final String display;
  final ValueChanged<double> onChanged;

  const _TextValueSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.display,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider.adaptive(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 64,
          child: Text(
            display,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _NativeVoiceRow extends StatelessWidget {
  final String label;
  final List<Map> voices;
  final Map<String, String>? initialValue;
  final ValueChanged<Map<String, String>> onChanged;

  const _NativeVoiceRow({
    required this.label,
    required this.voices,
    this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (voices.isEmpty) {
      return Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      );
    }
    Map selected = voices.first;
    if (initialValue != null) {
      final match = voices.where(
        (v) => v['name'] == initialValue!['name'],
      );
      if (match.isNotEmpty) selected = match.first;
    }
    return DropdownButtonFormField<Map>(
      isExpanded: true,
      initialValue: selected,
      items: [
        for (final (i, v) in voices.indexed)
          DropdownMenuItem(
            value: v,
            child: Text('$label — Voice ${i + 1}'),
          ),
      ],
      onChanged: (v) {
        if (v != null) {
          onChanged(
            v.map((k, value) => MapEntry(k.toString(), value.toString())),
          );
        }
      },
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        border: OutlineInputBorder(borderRadius: context.appRadius(10)),
      ),
    );
  }
}
