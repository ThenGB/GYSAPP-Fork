import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

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
  final Map<String, CancelToken> _downloadTokens = {};

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

  Future<void> _refreshLocalStatuses() async {
    try {
      final statuses = await _service.loadStatuses();
      if (!isClosed) emit(state.copyWith(statuses: statuses));
    } catch (e, st) {
      log('Local asset status refresh failed', error: e, stackTrace: st);
    }
  }

  Future<void> downloadAsset(
    AssetDefinition definition, {
    BibleCubit? bibleCubit,
    SongCubit? songCubit,
    Future<void> Function()? onInstalled,
  }) async {
    final code = definition.code;
    if (_downloadTokens.containsKey(code)) return;

    final cancelToken = CancelToken();
    _downloadTokens[code] = cancelToken;
    emit(
      state.copyWith(
        progressByCode: {...state.progressByCode, code: 0},
        cancellingCodes: {...state.cancellingCodes}..remove(code),
        installingCodes: {...state.installingCodes}..remove(code),
        message: null,
      ),
    );

    try {
      await _service.downloadAndInstall(
        definition,
        cancelToken: cancelToken,
        onDownloadComplete: () {
          if (isClosed) return;
          emit(
            state.copyWith(
              progressByCode: {...state.progressByCode, code: 1},
              cancellingCodes: {...state.cancellingCodes}..remove(code),
              installingCodes: {...state.installingCodes, code},
            ),
          );
        },
        onProgress: (received, total) {
          if (isClosed || cancelToken.isCancelled) return;
          final next = total <= 0 ? 0.0 : received / total;
          emit(
            state.copyWith(
              progressByCode: {...state.progressByCode, code: next},
            ),
          );
        },
      );
      if (isClosed) return;

      // Show the new local install immediately, then notify feature cubits so
      // their selectors/libraries update in the same frame sequence. No app
      // restart and no second remote-manifest fetch is required.
      await _refreshLocalStatuses();
      await _refreshConsumers(
        definition,
        bibleCubit: bibleCubit,
        songCubit: songCubit,
      );
      await onInstalled?.call();
      if (isClosed) return;

      emit(
        state.copyWith(
          progressByCode: {...state.progressByCode}..remove(code),
          cancellingCodes: {...state.cancellingCodes}..remove(code),
          installingCodes: {...state.installingCodes}..remove(code),
          message: '${definition.title} is ready for offline use.',
        ),
      );
    } on AssetDownloadCancelled {
      if (isClosed) return;
      emit(
        state.copyWith(
          progressByCode: {...state.progressByCode}..remove(code),
          cancellingCodes: {...state.cancellingCodes}..remove(code),
          installingCodes: {...state.installingCodes}..remove(code),
          message: '${definition.title} download stopped.',
        ),
      );
    } catch (e, st) {
      log('Asset download failed', error: e, stackTrace: st);
      if (isClosed) return;
      emit(
        state.copyWith(
          progressByCode: {...state.progressByCode}..remove(code),
          cancellingCodes: {...state.cancellingCodes}..remove(code),
          installingCodes: {...state.installingCodes}..remove(code),
          message: 'Failed to download ${definition.title}.',
        ),
      );
    } finally {
      if (identical(_downloadTokens[code], cancelToken)) {
        _downloadTokens.remove(code);
      }
    }
  }

  void cancelDownload(String code) {
    if (state.installingCodes.contains(code)) return;
    final token = _downloadTokens[code];
    if (token == null || token.isCancelled) return;
    emit(
      state.copyWith(
        cancellingCodes: {...state.cancellingCodes, code},
        message: null,
      ),
    );
    token.cancel('Download stopped by user.');
  }

  Future<void> deleteAsset(
    AssetDefinition definition, {
    BibleCubit? bibleCubit,
    SongCubit? songCubit,
    Future<void> Function()? onDeleted,
  }) async {
    await _service.deleteInstalled(definition);
    await _refreshLocalStatuses();
    await _refreshConsumers(
      definition,
      bibleCubit: bibleCubit,
      songCubit: songCubit,
    );
    await onDeleted?.call();
    if (isClosed) return;
    emit(
      state.copyWith(
        message: '${definition.title} was removed from local storage.',
      ),
    );
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

  @override
  Future<void> close() {
    // Only network-stage downloads are cancellable. Installing transactions
    // are allowed to finish so an app navigation event cannot corrupt an
    // update that already has the complete package.
    for (final entry in _downloadTokens.entries) {
      if (!state.installingCodes.contains(entry.key) && !entry.value.isCancelled) {
        entry.value.cancel('Asset manager closed.');
      }
    }
    _downloadTokens.clear();
    return super.close();
  }
}
