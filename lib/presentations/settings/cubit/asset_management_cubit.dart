import 'dart:developer';

import 'package:bloc/bloc.dart';

import '../../../data/services/app_reset_service.dart';
import '../../../data/services/asset_distribution/asset_distribution_service.dart';
import '../../../data/services/asset_distribution/models.dart';
import '../../bible/cubit/bible_cubit.dart';
import '../../song/cubit/song_cubit.dart';
import 'asset_management_state.dart';

class AssetManagementCubit extends Cubit<AssetManagementState> {
  AssetManagementCubit(this._service, this._appResetService)
    : super(const AssetManagementState());

  final AssetDistributionService _service;
  final AppResetService _appResetService;

  Future<void> refresh() async {
    emit(state.copyWith(isLoading: true, message: null));
    try {
      await _service.refreshRemoteState();
      final statuses = await _service.loadStatuses();
      emit(state.copyWith(isLoading: false, statuses: statuses, message: null));
    } catch (e, st) {
      log('Asset refresh failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          isLoading: false,
          message: 'Failed to refresh asset list.',
        ),
      );
    }
  }

  Future<void> downloadAsset(
    AssetDefinition definition, {
    BibleCubit? bibleCubit,
    SongCubit? songCubit,
  }) async {
    emit(
      state.copyWith(
        progressByCode: {...state.progressByCode, definition.code: 0},
        message: null,
      ),
    );
    try {
      await _service.downloadAndInstall(
        definition,
        onProgress: (received, total) {
          final next = total <= 0 ? 0.0 : received / total;
          emit(
            state.copyWith(
              progressByCode: {...state.progressByCode, definition.code: next},
            ),
          );
        },
      );
      emit(
        state.copyWith(
          progressByCode: {...state.progressByCode}..remove(definition.code),
          message: '${definition.title} is ready for offline use.',
        ),
      );
      await _refreshConsumers(
        definition,
        bibleCubit: bibleCubit,
        songCubit: songCubit,
      );
      await refresh();
    } catch (e, st) {
      log('Asset download failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          progressByCode: {...state.progressByCode}..remove(definition.code),
          message: 'Failed to download ${definition.title}.',
        ),
      );
    }
  }

  Future<void> deleteAsset(
    AssetDefinition definition, {
    BibleCubit? bibleCubit,
    SongCubit? songCubit,
  }) async {
    await _service.deleteInstalled(definition);
    emit(
      state.copyWith(
        message: '${definition.title} was removed from local storage.',
      ),
    );
    await _refreshConsumers(
      definition,
      bibleCubit: bibleCubit,
      songCubit: songCubit,
    );
    await refresh();
  }

  Future<void> clearFastAccessCache() async {
    emit(state.copyWith(isClearingCache: true, message: null));
    try {
      await _service.clearFastAccessCache();
      emit(
        state.copyWith(
          isClearingCache: false,
          message: 'Fast-access cache deleted.',
        ),
      );
    } catch (e, st) {
      log('Cache clear failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          isClearingCache: false,
          message: 'Failed to delete fast-access cache.',
        ),
      );
    }
  }

  Future<bool> resetAppData() async {
    emit(state.copyWith(isResettingApp: true, message: null));
    try {
      await _appResetService.wipeEverything();
      emit(
        state.copyWith(
          isResettingApp: false,
          message: 'All app data was removed. Restarting first-time setup...',
        ),
      );
      return true;
    } catch (e, st) {
      log('App reset failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          isResettingApp: false,
          message: 'Failed to reset the application data.',
        ),
      );
      return false;
    }
  }

  Future<void> _refreshConsumers(
    AssetDefinition definition, {
    BibleCubit? bibleCubit,
    SongCubit? songCubit,
  }) async {
    if (definition.kind == DistributedAssetKind.bible && bibleCubit != null) {
      await bibleCubit.refreshAvailableBibles();
    }
    if (definition.kind == DistributedAssetKind.hymnal && songCubit != null) {
      await songCubit.refreshLibraryAvailability();
    }
  }
}
