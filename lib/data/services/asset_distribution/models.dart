enum DistributedAssetKind { bible, hymnal }

enum AssetReleaseTrack { bibles, hymnals }

class AssetDefinition {
  const AssetDefinition({
    required this.kind,
    required this.code,
    required this.title,
    required this.installFileName,
    required this.bundledByDefault,
    required this.releaseTrack,
  });

  final DistributedAssetKind kind;
  final String code;
  final String title;
  final String installFileName;
  final bool bundledByDefault;
  final AssetReleaseTrack releaseTrack;
}

class InstalledAssetRecord {
  const InstalledAssetRecord({
    required this.kind,
    required this.code,
    required this.version,
    required this.installedPath,
    required this.installedAtEpochMs,
    this.releaseTag,
    this.checksumSha256,
  });

  final DistributedAssetKind kind;
  final String code;
  final String version;
  final String installedPath;
  final int installedAtEpochMs;
  final String? releaseTag;
  final String? checksumSha256;

  Map<String, dynamic> toJson() {
    return {
      'kind': kind.name,
      'code': code,
      'version': version,
      'installedPath': installedPath,
      'installedAtEpochMs': installedAtEpochMs,
      'releaseTag': releaseTag,
      'checksumSha256': checksumSha256,
    };
  }

  factory InstalledAssetRecord.fromJson(Map<String, dynamic> json) {
    return InstalledAssetRecord(
      kind: DistributedAssetKind.values.byName(json['kind'] as String),
      code: json['code'] as String? ?? '',
      version: json['version'] as String? ?? '',
      installedPath: json['installedPath'] as String? ?? '',
      installedAtEpochMs: json['installedAtEpochMs'] as int? ?? 0,
      releaseTag: json['releaseTag'] as String?,
      checksumSha256: json['checksumSha256'] as String?,
    );
  }

  String get key => '${kind.name}:$code';
}

class RemoteAssetPackage {
  const RemoteAssetPackage({
    required this.code,
    required this.version,
    required this.fileName,
    required this.downloadUrl,
    required this.installFileName,
    required this.sizeBytes,
    this.checksumSha256,
  });

  final String code;
  final String version;
  final String fileName;
  final String downloadUrl;
  final String installFileName;
  final int sizeBytes;
  final String? checksumSha256;

  factory RemoteAssetPackage.fromJson(Map<String, dynamic> json) {
    return RemoteAssetPackage(
      code: json['code'] as String? ?? '',
      version: json['version'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      downloadUrl: json['downloadUrl'] as String? ?? '',
      installFileName: json['installFileName'] as String? ?? '',
      sizeBytes: json['sizeBytes'] as int? ?? 0,
      checksumSha256: json['checksumSha256'] as String?,
    );
  }
}

class RemoteAssetManifest {
  const RemoteAssetManifest({
    required this.track,
    required this.releaseTag,
    required this.publishedAt,
    required this.packages,
  });

  final AssetReleaseTrack track;
  final String releaseTag;
  final DateTime publishedAt;
  final List<RemoteAssetPackage> packages;
}

class ManagedAssetStatus {
  const ManagedAssetStatus({
    required this.definition,
    this.installedRecord,
    this.remotePackage,
  });

  final AssetDefinition definition;
  final InstalledAssetRecord? installedRecord;
  final RemoteAssetPackage? remotePackage;

  bool get isBundled => definition.bundledByDefault && installedRecord == null;
  bool get isInstalled =>
      installedRecord != null || definition.bundledByDefault;
  bool get isDownloaded => installedRecord != null;
  bool get hasRemotePackage => remotePackage != null;
  String? get installedVersion => installedRecord?.version;
  String? get remoteVersion => remotePackage?.version;
  bool get canDelete => installedRecord != null;

  bool get hasUpdateAvailable {
    final remote = remotePackage;
    if (remote == null) return false;
    if (installedRecord == null) {
      return definition.bundledByDefault;
    }
    return installedRecord!.version != remote.version;
  }
}

const supportedDistributedAssets = <AssetDefinition>[
  AssetDefinition(
    kind: DistributedAssetKind.bible,
    code: 'b_tb',
    title: 'Terjemahan Baru',
    installFileName: 'b_tb.db',
    bundledByDefault: true,
    releaseTrack: AssetReleaseTrack.bibles,
  ),
  AssetDefinition(
    kind: DistributedAssetKind.bible,
    code: 'b_kjv',
    title: 'King James Version',
    installFileName: 'b_kjv.db',
    bundledByDefault: false,
    releaseTrack: AssetReleaseTrack.bibles,
  ),
  AssetDefinition(
    kind: DistributedAssetKind.bible,
    code: 'b_cuv',
    title: 'Chinese Union Version',
    installFileName: 'b_cuv.db',
    bundledByDefault: false,
    releaseTrack: AssetReleaseTrack.bibles,
  ),
  AssetDefinition(
    kind: DistributedAssetKind.hymnal,
    code: 'KR',
    title: 'Kidung Rohani',
    installFileName: 'kr_master.pdf',
    bundledByDefault: true,
    releaseTrack: AssetReleaseTrack.hymnals,
  ),
  AssetDefinition(
    kind: DistributedAssetKind.hymnal,
    code: 'HYMNE',
    title: 'Hymne (English Version)',
    installFileName: 'hymne_master.pdf',
    bundledByDefault: false,
    releaseTrack: AssetReleaseTrack.hymnals,
  ),
  AssetDefinition(
    kind: DistributedAssetKind.hymnal,
    code: 'MDR',
    title: 'Mandarin',
    installFileName: 'mdr_master.pdf',
    bundledByDefault: false,
    releaseTrack: AssetReleaseTrack.hymnals,
  ),
  AssetDefinition(
    kind: DistributedAssetKind.hymnal,
    code: 'ASM-I',
    title: 'Aku Senang Menyanyi I',
    installFileName: 'asm_i_master.pdf',
    bundledByDefault: false,
    releaseTrack: AssetReleaseTrack.hymnals,
  ),
  AssetDefinition(
    kind: DistributedAssetKind.hymnal,
    code: 'ASM-M',
    title: 'Aku Senang Menyanyi M',
    installFileName: 'asm_m_master.pdf',
    bundledByDefault: false,
    releaseTrack: AssetReleaseTrack.hymnals,
  ),
  AssetDefinition(
    kind: DistributedAssetKind.hymnal,
    code: 'ASM-P',
    title: 'Aku Senang Menyanyi P',
    installFileName: 'asm_p_master.pdf',
    bundledByDefault: false,
    releaseTrack: AssetReleaseTrack.hymnals,
  ),
];

AssetDefinition? assetDefinitionForCode(
  DistributedAssetKind kind,
  String code,
) {
  for (final asset in supportedDistributedAssets) {
    if (asset.kind == kind && asset.code == code) {
      return asset;
    }
  }
  return null;
}
