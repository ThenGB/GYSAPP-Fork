import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../components/components.dart';
import '../../../data/data.dart';
import '../../../router/router.dart';

@RoutePage()
class BibleAudioSettingView extends StatefulWidget {
  final Map<String, Map> initialVoices;
  final double initialPitchRate;
  final double initialSpeedRate;
  final Function(Map<String, Map> voices, double pitch, double speed) onSave;
  const BibleAudioSettingView({
    super.key,
    required this.initialVoices,
    required this.initialPitchRate,
    required this.initialSpeedRate,
    required this.onSave,
  });

  @override
  State<BibleAudioSettingView> createState() => _BibleAudioSettingViewState();
}

class _BibleAudioSettingViewState extends State<BibleAudioSettingView> {
  FlutterTts? tts = isTextToSpeechConfiguredForCurrentPlatform
      ? FlutterTts()
      : null;
  List<String> availableTtsLang = [];
  List<Map> availableVoices = [];

  late Map<String, Map> voices = Map.from(widget.initialVoices);
  late double pitch = widget.initialPitchRate;
  late double speed = widget.initialSpeedRate;

  List<Map> voicesByLocale(String locale) {
    return availableVoices
        .where((element) => element['locale'] == locale)
        .toList();
  }

  Future<void> speak(String sentence, String locale) async {
    final tts = this.tts;
    if (tts == null) {
      try {
        Fluttertoast.cancel();
      } catch (_) {}
      try {
        Fluttertoast.showToast(msg: 'Not available'.tr());
      } catch (_) {}
      return;
    }

    if (isSpeaking) {
      try {
        await tts.stop();
      } catch (_) {}
      isSpeaking = false;
      if (isLangSpeaking(locale)) {
        langSpeaking = '';
        return;
      }
    }
    await Future.delayed(Duration(milliseconds: 200));
    try {
      await tts.awaitSpeakCompletion(true);
    } catch (_) {}
    await tts.setLanguage(locale);
    var voiceForLocale = voices[locale];
    if (voiceForLocale != null) {
      try {
        await tts.setVoice(voiceForLocale.cast());
      } catch (_) {}
    }
    await tts.setPitch(pitch);
    await tts.setSpeechRate(speed);
    langSpeaking = locale;
    isSpeaking = true;
    try {
      await tts.speak(sentence);
    } catch (e) {
      try {
        Fluttertoast.cancel();
      } catch (_) {}
      try {
        Fluttertoast.showToast(msg: Failure.fromError(e).message);
      } catch (_) {}
    }
    langSpeaking = '';
    isSpeaking = false;
  }

  bool _isSpeaking = false;

  String _langSpeaking = '';

  bool isLangSpeaking(String locale) => _langSpeaking == locale;

  set langSpeaking(String value) {
    _langSpeaking = value;
    setState(() {});
  }

  bool get isSpeaking => _isSpeaking;

  set isSpeaking(bool value) {
    setState(() {
      _isSpeaking = value;
    });
  }

  @override
  void initState() {
    final tts = this.tts;
    if (tts == null) {
      super.initState();
      return;
    }

    tts.getLanguages
        .then((value) {
          try {
            var supportedLangPrefixes = {
              'id': 'id-ID',
              'en': 'en-US',
              'zh': 'zh-CN',
            };
            var values = (value as List<Object?>).cast<String>().toList();
            var filtered = values
                .where(
                  (element) =>
                      supportedLangPrefixes.containsKey(element) ||
                      supportedLangPrefixes.containsValue(element) ||
                      supportedLangPrefixes.containsKey(
                        element.split('-').first,
                      ) ||
                      supportedLangPrefixes.containsValue(
                        element.split('-').first,
                      ),
                )
                .toList();
            if (filtered.isEmpty) {
              filtered = values.where((element) {
                var prefix = element.split('-').first;
                return supportedLangPrefixes.containsKey(prefix);
              }).toList();
            }
            availableTtsLang = List.from(filtered);
          } catch (e) {
            log('TTS getLanguages failed: $e', name: 'AudioSettings');
          }
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              setState(() {});
            });
          }
        })
        .catchError((e) {
          log('TTS getLanguages error: $e', name: 'AudioSettings');
        });
    Future.microtask(() async {
      try {
        availableVoices = (await tts.getVoices as List<Object?>)
            .cast<Map>()
            .toList()
            .map(
              (e) => e.map(
                (key, value) => MapEntry(key.toString(), value.toString()),
              ),
            )
            .toList();
      } catch (e) {
        log('TTS getVoices failed: $e', name: 'AudioSettings');
      }
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    if (isSpeaking || canStopIdleTextToSpeechForCurrentPlatform) {
      tts?.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(color: context.colorScheme.secondaryContainer),
        ),
        title: Text('Audio Bible Config'.tr()),
      ),
      bottomNavigationBar: BottomAppBar(
        color: context.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.primary,
            foregroundColor: context.colorScheme.onPrimary,
          ),
          onPressed: () {
            context
                .showConfirmation(
                  'Are you sure want to save this preferences?'.tr(),
                )
                .then((confirmed) {
                  router.maybePop();
                  try {
                    Fluttertoast.cancel();
                  } catch (_) {}
                  try {
                    Fluttertoast.showToast(msg: 'Saved'.tr());
                  } catch (_) {}
                  widget.onSave(voices, pitch, speed);
                });
          },
          child: Text('Save'.tr()),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Section(
              label: 'Voice'.tr(),
              child: (gap) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: availableTtsLang.contains('id-ID') ? 1 : .4,
                    child: IgnorePointer(
                      ignoring: !availableTtsLang.contains('id-ID'),
                      child: Stack(
                        children: [
                          Section(
                            label: 'Bahasa Indonesia',
                            child: (gap) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: gap),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('tts_bahasa_placeholder'.tr()),
                                  SizedBox(height: 4),
                                  OverflowBar(
                                    // buttonAlignedDropdown: true,
                                    // layoutBehavior:
                                    //     ButtonBarLayoutBehavior.constrained,
                                    alignment: MainAxisAlignment.start,
                                    children: [
                                      PopupMenuButton(
                                        initialValue: voices['id-ID'],
                                        onSelected: (value) {
                                          voices['id-ID'] = value;
                                          setState(() {});
                                        },
                                        itemBuilder: (context) {
                                          return voicesByLocale('id-ID')
                                              .asMap()
                                              .entries
                                              .map(
                                                (e) => PopupMenuItem(
                                                  value: e.value,
                                                  child: Text(
                                                    'Voice ${e.key + 1}',
                                                  ),
                                                ),
                                              )
                                              .toList();
                                        },
                                        child: Row(
                                          children: [
                                            Text(() {
                                              var index =
                                                  voicesByLocale('id-ID')
                                                      .map((e) => e['name'])
                                                      .toList()
                                                      .indexOf(
                                                        voices['id-ID']?['name'],
                                                      );

                                              return 'Voice ${index + 1}';
                                            }()),
                                            SizedBox(width: 4),
                                            Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              size: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor:
                                              isLangSpeaking('id-ID')
                                              ? context
                                                    .colorScheme
                                                    .secondaryContainer
                                              : context.colorScheme.primary,
                                          foregroundColor:
                                              isLangSpeaking('id-ID')
                                              ? context
                                                    .colorScheme
                                                    .onSecondaryContainer
                                              : context.colorScheme.onPrimary,
                                        ),
                                        onPressed: () {
                                          speak(
                                            'tts_bahasa_placeholder'.tr(),
                                            'id-ID',
                                          );
                                        },
                                        child: Text(
                                          isLangSpeaking('id-ID')
                                              ? 'Stop'.tr()
                                              : 'Speak'.tr(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!availableTtsLang.contains('id-ID'))
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(2),
                                  color: context.colorScheme.error,
                                  child: Text(
                                    'Not available'.tr(),
                                    style: TextStyle(
                                      color: context.colorScheme.onError,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Section(
                    label: 'English',
                    child: (gap) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: gap),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('tts_english_placeholder'.tr()),
                          SizedBox(height: 4),
                          OverflowBar(
                            // buttonAlignedDropdown: true,
                            // layoutBehavior: ButtonBarLayoutBehavior.constrained,
                            alignment: MainAxisAlignment.start,
                            children: [
                              PopupMenuButton(
                                initialValue: voices['en-US'],
                                onSelected: (value) {
                                  voices['en-US'] = value;
                                  setState(() {});
                                },
                                itemBuilder: (context) {
                                  return voicesByLocale('en-US')
                                      .asMap()
                                      .entries
                                      .map(
                                        (e) => PopupMenuItem(
                                          value: e.value,
                                          child: Text('Voice ${e.key + 1}'),
                                        ),
                                      )
                                      .toList();
                                },
                                child: Row(
                                  children: [
                                    Text(() {
                                      var langId = 'en-US';
                                      var index = voicesByLocale(langId)
                                          .map((e) => e['name'])
                                          .toList()
                                          .indexOf(voices[langId]?['name']);

                                      return 'Voice ${index + 1}';
                                    }()),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: isLangSpeaking('en-US')
                                      ? context.colorScheme.secondaryContainer
                                      : context.colorScheme.primary,
                                  foregroundColor: isLangSpeaking('en-US')
                                      ? context.colorScheme.onSecondaryContainer
                                      : context.colorScheme.onPrimary,
                                ),
                                onPressed: () {
                                  speak(
                                    'tts_english_placeholder'.tr(),
                                    'en-US',
                                  );
                                },
                                child: Text(
                                  isLangSpeaking('en-US')
                                      ? 'Stop'.tr()
                                      : 'Speak'.tr(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Section(
                    label: 'Chinese',
                    child: (gap) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: gap),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('tts_chinese_placeholder'.tr()),
                          SizedBox(height: 4),
                          OverflowBar(
                            // buttonAlignedDropdown: true,
                            // layoutBehavior: ButtonBarLayoutBehavior.constrained,
                            alignment: MainAxisAlignment.start,
                            children: [
                              PopupMenuButton(
                                initialValue: voices['zh-CN'],
                                onSelected: (value) {
                                  voices['zh-CN'] = value;
                                  setState(() {});
                                },
                                itemBuilder: (context) {
                                  return voicesByLocale('zh-CN')
                                      .asMap()
                                      .entries
                                      .map(
                                        (e) => PopupMenuItem(
                                          value: e.value,
                                          child: Text('Voice ${e.key + 1}'),
                                        ),
                                      )
                                      .toList();
                                },
                                child: Row(
                                  children: [
                                    Text(() {
                                      var langId = 'zh-CN';
                                      var index = voicesByLocale(langId)
                                          .map((e) => e['name'])
                                          .toList()
                                          .indexOf(voices[langId]?['name']);

                                      return 'Voice ${index + 1}';
                                    }()),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: isLangSpeaking('zh-CN')
                                      ? context.colorScheme.secondaryContainer
                                      : context.colorScheme.primary,
                                  foregroundColor: isLangSpeaking('zh-CN')
                                      ? context.colorScheme.onSecondaryContainer
                                      : context.colorScheme.onPrimary,
                                ),
                                onPressed: () {
                                  speak(
                                    'tts_chinese_placeholder'.tr(),
                                    'zh-CN',
                                  );
                                },
                                child: Text(
                                  isLangSpeaking('zh-CN')
                                      ? 'Stop'.tr()
                                      : 'Speak'.tr(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Section(
              label: 'Pitch Rate'.tr(),
              child: (gap) => Padding(
                padding: EdgeInsets.symmetric(horizontal: gap),
                child: Slider.adaptive(
                  value: pitch,
                  label: '$pitch ${'rate'.tr()}',
                  onChanged: (value) {
                    pitch = value;
                    setState(() {});
                  },
                ),
              ),
            ),
            Section(
              label: 'Speed Rate'.tr(),
              child: (gap) => Padding(
                padding: EdgeInsets.symmetric(horizontal: gap),
                child: Slider.adaptive(
                  value: speed,
                  label: '$speed ${'rate'.tr()}',
                  onChanged: (value) {
                    speed = value;
                    setState(() {});
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
