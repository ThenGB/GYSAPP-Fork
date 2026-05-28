import 'dart:developer';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/services/ourmanna_service.dart';
import '../../../data/utilities/app_config_store.dart';
import '../../../domain/entity/banner/banner.dart';
import '../../../domain/entity/menulink/menulink_entity.dart';
import '../../../domain/entity/sauh/sauh_entity.dart';
import '../../../domain/repository/scrapper_repository.dart';
import 'home_state.dart';

export 'home_state.dart';

class HomeCubit extends HydratedCubit<HomeState> {
  final ScrapperRepository repository;
  final OurMannnaService ourMannnaService;

  List<String> bibleCodes = [];

  late BehaviorSubject<List<ImageBanner>> rxBanner =
      BehaviorSubject<List<ImageBanner>>.seeded([]);

  ValueStream<List<ImageBanner>> get bannerObservable => rxBanner.stream;
  HomeCubit(this.repository, this.ourMannnaService) : super(const HomeState()) {
    final freshSauhs = freshSauhCacheForToday(state.sauhs);
    if (freshSauhs.length != state.sauhs.length) {
      emit(state.copyWith(sauhs: freshSauhs));
    }
    scrappSauhBagiJiwa();
    scrappTrueVoice();
    getMenu();
    getPrimaryMenuStatus();
    fetchTodayVerse();
  }

  Future<void> fetchTodayVerse() async {
    String? bibleCode;
    try {
      final data = HydratedBloc.storage.read('BibleCubit') as Map<String, dynamic>?;
      if (data != null) {
        bibleCode = data['currentBibleCode'] as String?;
        final codes = data['bibleCodes'];
        if (codes is List) {
          bibleCodes = codes.cast<String>().toList();
        }
        log('TodayVerse: bibleCode=$bibleCode, bibleCodes=$bibleCodes', name: 'HomeCubit');
      } else {
        log('TodayVerse: BibleCubit not found in HydratedStorage', name: 'HomeCubit');
      }
    } catch (e) {
      log('TodayVerse: Error reading bibleCode: $e', name: 'HomeCubit');
    }

    final verse = await ourMannnaService.getVerse(bibleCode: bibleCode);
    if (verse != null) {
      log('TodayVerse: text=${verse.text.substring(0, 50)}..., ref=${verse.reference}, codeName=${verse.bibleCodeName}', name: 'HomeCubit');
      emit(state.copyWith(todayVerse: verse));
    }
  }

  Future<void> switchTodayVerseBible(String bibleCode) async {
    final verse = await ourMannnaService.getVerse(bibleCode: bibleCode);
    if (verse != null) {
      emit(state.copyWith(todayVerse: verse));
    }
  }

  void refresh() {
    scrappSauhBagiJiwa();
    scrappTrueVoice();
    getMenu();
    getPrimaryMenuStatus();
  }

  Future<void> getMenu() async {
    var appMenuJson = await AppConfigStore.listMapConfig('app_menu');
    final List<Menulink> menuLinks = appMenuJson
        .map<Menulink>((e) => Menulink.fromJson(e))
        .toList();

    emit(state.copyWith(menuLinks: menuLinks));
  }

  Future<void> getPrimaryMenuStatus() async {
    var appMenuJson = await AppConfigStore.jsonConfig('primary_menu');
    final isSuaraSejatiEnabled = _configFlag(
      appMenuJson['suara_sejati'],
      defaultValue: true,
    );
    final isSauhEnabled = _configFlag(
      appMenuJson['sauh_bagi_jiwa'],
      defaultValue: true,
    );
    emit(
      state.copyWith(
        isSuaraSejatiEnabled: isSuaraSejatiEnabled,
        isSauhEnabled: isSauhEnabled,
      ),
    );
  }

  Future<void> scrappSauhBagiJiwa() async {
    var result = await repository.getSauh();
    result.fold((failure) {}, (res) {
      emit(state.copyWith(sauhs: res));
    });
  }

  Future<void> scrappTrueVoice() async {
    log('SS: Starting fetch', name: 'HomeCubit');
    var result = await repository.getSuaraSejati();
    result.fold((failure) {
      log('SS: Failed to fetch - $failure', name: 'HomeCubit');
    }, (res) {
      log('SS: Successfully fetched ${res.length} items', name: 'HomeCubit');
      emit(state.copyWith(trueVoices: res));
      log('SS: State updated, isSuaraSejatiEnabled=${state.isSuaraSejatiEnabled}', name: 'HomeCubit');
    });
  }

  @override
  HomeState? fromJson(Map<String, dynamic> json) {
    final restored = HomeState.fromJson(json);
    return restored.copyWith(sauhs: freshSauhCacheForToday(restored.sauhs));
  }

  @override
  Map<String, dynamic>? toJson(HomeState state) {
    return state.toJson();
  }
}

List<Sauh> freshSauhCacheForToday(
  List<Sauh> sauhs, {
  DateTime? now,
}) {
  if (sauhs.isEmpty) return sauhs;
  final expectedSlug = _expectedSauhSlugForDate(now ?? DateTime.now());
  final currentSlug = _extractSauhSlugFromUrl(sauhs.first.url);
  if (currentSlug == null) return const [];
  return currentSlug == expectedSlug ? sauhs : const [];
}

String _expectedSauhSlugForDate(DateTime date) {
  final local = date.toLocal();
  final yy = (local.year % 100).toString().padLeft(2, '0');
  final mm = local.month.toString().padLeft(2, '0');
  final dd = local.day.toString().padLeft(2, '0');
  return 'sbj$yy$mm$dd';
}

String? _extractSauhSlugFromUrl(String url) {
  final path = Uri.tryParse(url)?.path ?? url;
  final match = RegExp(r'(sbj\d{6})/?$', caseSensitive: false).firstMatch(path);
  return match?.group(1)?.toLowerCase();
}

bool _configFlag(Object? value, {required bool defaultValue}) {
  if (value is bool) return value;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
  }
  return defaultValue;
}
