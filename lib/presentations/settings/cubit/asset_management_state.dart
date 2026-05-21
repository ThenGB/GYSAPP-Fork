import '../../../data/services/asset_distribution/models.dart';

class AssetManagementState {
  const AssetManagementState({
    this.isLoading = false,
    this.isClearingCache = false,
    this.isResettingApp = false,
    this.statuses = const [],
    this.progressByCode = const {},
    this.message,
  });

  final bool isLoading;
  final bool isClearingCache;
  final bool isResettingApp;
  final List<ManagedAssetStatus> statuses;
  final Map<String, double> progressByCode;
  final String? message;

  AssetManagementState copyWith({
    bool? isLoading,
    bool? isClearingCache,
    bool? isResettingApp,
    List<ManagedAssetStatus>? statuses,
    Map<String, double>? progressByCode,
    String? message,
  }) {
    return AssetManagementState(
      isLoading: isLoading ?? this.isLoading,
      isClearingCache: isClearingCache ?? this.isClearingCache,
      isResettingApp: isResettingApp ?? this.isResettingApp,
      statuses: statuses ?? this.statuses,
      progressByCode: progressByCode ?? this.progressByCode,
      message: message,
    );
  }

  List<ManagedAssetStatus> get bibleStatuses => statuses
      .where((status) => status.definition.kind == DistributedAssetKind.bible)
      .toList();

  List<ManagedAssetStatus> get hymnalStatuses => statuses
      .where((status) => status.definition.kind == DistributedAssetKind.hymnal)
      .toList();
}
