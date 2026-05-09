import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:share_plus/share_plus.dart';

import '../../../components/components.dart';
import '../../../data/data.dart';
import '../../../di/injection.dart';
import '../../../domain/domain.dart';
import '../../presentations.dart';
import '../widget/sync_confirm_dialog.dart';

@RoutePage()
class BackupView extends StatefulWidget {
  final AppBackupData data;
  final Function(AppBackupData data) onSynced;
  const BackupView({super.key, required this.data, required this.onSynced});

  @override
  State<BackupView> createState() => _BackupViewState();
}

class _BackupViewState extends State<BackupView> {
  GoogleSignInAccount? currentUser;

  bool get canUseCloudBackup => isGoogleSignInConfiguredForCurrentPlatform;

  @override
  void initState() {
    if (canUseCloudBackup) {
      currentUser = di<GoogleSignIn>().currentUser;
    }
    context.read<BackupCubit>().initLocalData(widget.data);
    context.read<BackupCubit>().getDataSummary();
    super.initState();
  }

  File? localBackupFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Kidung Rohani'),
        shape: Border(
          bottom: BorderSide(
            color: context.colorScheme.secondaryContainer,
          ),
        ),
      ),
      body: BlocBuilder<BackupCubit, BackupState>(
        builder: (context, state) => SingleChildScrollView(
          // padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Section(
                  label: 'Data Backup'.tr(),
                  child: (gap) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: gap),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   'Backup Your Data'.tr(),
                        //   style: TextStyle(
                        //     fontWeight: FontWeight.bold,
                        //     fontSize: 16,
                        //   ),
                        // ),
                        // SizedBox(height: 8),
                        Text(
                          'data_backup_desc'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textDisplayColor,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text.rich(
                          TextSpan(
                            text: '${'Account'.tr()}: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: currentUser?.email ?? 'Unauthorized'.tr(),
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: TextButton(
                                  onPressed: !canUseCloudBackup
                                      ? null
                                      : () async {
                                          if (await di<GoogleSignIn>()
                                              .isSignedIn()) {
                                            await di<GoogleSignIn>().signOut();
                                          }
                                          currentUser = await di<GoogleSignIn>()
                                              .signIn();
                                          setState(() {});
                                        },
                                  child: FutureBuilder(
                                    future: canUseCloudBackup
                                        ? di<GoogleSignIn>().isSignedIn()
                                        : Future.value(false),
                                    builder: (context, snapshot) => Text(
                                      (snapshot.data == true
                                              ? 'Change account'
                                              : 'Login')
                                          .tr(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                minimumSize: Size(0, 48),
                                padding: EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  localBackupFile != null ? 8 : 16,
                                  8,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                backgroundColor: context.colorScheme.primary,
                                foregroundColor: context.colorScheme.onPrimary,
                              ),
                              onPressed: () async {
                                if (localBackupFile != null) {
                                  Share.shareXFiles(
                                    [
                                      XFile(
                                        localBackupFile!.path,
                                        name: 'MY GYS APP Save Data',
                                      ),
                                    ],
                                    subject: 'Hey check this out!'.tr(),
                                    text: 'My GYS APP Save Data, Try this!'
                                        .tr(),
                                  );
                                } else {
                                  localBackupFile = await context
                                      .read<BackupCubit>()
                                      .backupToLocal();
                                  setState(() {});
                                }
                              },
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Text(
                                      localBackupFile != null
                                          ? 'Share Backup File'.tr()
                                          : 'Local Backup'.tr(),
                                    ),
                                    if (localBackupFile != null) ...[
                                      VerticalDivider(
                                        color: context.colorScheme.onPrimary,
                                        width: 8,
                                      ),
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () {
                                            localBackupFile = null;
                                            setState(() {});
                                          },
                                          icon: Icon(Icons.refresh),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Column(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    minimumSize: Size(0, 48),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    backgroundColor:
                                        context.colorScheme.primary,
                                    foregroundColor:
                                        context.colorScheme.onPrimary,
                                  ),
                                  onPressed:
                                      !canUseCloudBackup ||
                                          currentUser == null ||
                                          state.isBackuping
                                      ? null
                                      : () {
                                          context
                                              .read<BackupCubit>()
                                              .backupToCloud();
                                        },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (state.isBackuping) ...[
                                        SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: Center(
                                            child:
                                                CircularProgressIndicator.adaptive(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                        context
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                      ),
                                                ),
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                      ],
                                      Text(
                                        state.isBackuping
                                            ? 'Backuping'.tr()
                                            : 'Cloud Backup'.tr(),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!canUseCloudBackup)
                                  Text(
                                    '*${'Cloud backup is not available on Windows yet'.tr()}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: context.colorScheme.error,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  )
                                else if (currentUser == null)
                                  Text(
                                    '*${'Login required'.tr()}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: context.colorScheme.error,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Section(
                  label: 'Data Sync'.tr(),
                  child: (gap) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: gap),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   'Backup Your Data'.tr(),
                        //   style: TextStyle(
                        //     fontWeight: FontWeight.bold,
                        //     fontSize: 16,
                        //   ),
                        // ),
                        // SizedBox(height: 8),
                        Text(
                          'data_sync_desc'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textDisplayColor,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text.rich(
                          TextSpan(
                            text: '${'Account'.tr()}: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: currentUser?.email ?? 'Unauthorized'.tr(),
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                minimumSize: Size(0, 48),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                backgroundColor: context.colorScheme.primary,
                                foregroundColor: context.colorScheme.onPrimary,
                              ),
                              onPressed: () {
                                context.read<BackupCubit>().syncFromFile(
                                  onLoaded: (data) {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      isDismissible: true,
                                      enableDrag: true,
                                      builder: (c) {
                                        return SyncConfirmDialog(
                                          onConfirmed: () {
                                            widget.onSynced(data);
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: Text('Local Sync'.tr()),
                            ),
                            SizedBox(width: 8),
                            Column(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    minimumSize: Size(0, 48),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    backgroundColor:
                                        context.colorScheme.primary,
                                    foregroundColor:
                                        context.colorScheme.onPrimary,
                                  ),
                                  onPressed:
                                      !canUseCloudBackup ||
                                          currentUser == null ||
                                          state.isSyncing
                                      ? null
                                      : () {
                                          context
                                              .read<BackupCubit>()
                                              .syncFromCloud(
                                                onLoaded: (data) {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    isDismissible: true,
                                                    enableDrag: true,
                                                    builder: (c) {
                                                      return SyncConfirmDialog(
                                                        onConfirmed: () {
                                                          widget.onSynced(data);
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                        },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (state.isSyncing) ...[
                                        SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: Center(
                                            child:
                                                CircularProgressIndicator.adaptive(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                        context
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                      ),
                                                ),
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                      ],
                                      Text(
                                        state.isSyncing
                                            ? 'Syncing'.tr()
                                            : 'Cloud Sync'.tr(),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!canUseCloudBackup)
                                  Text(
                                    '*${'Cloud sync is not available on Windows yet'.tr()}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: context.colorScheme.error,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  )
                                else if (currentUser == null)
                                  Text(
                                    '*${'Login required'.tr()}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: context.colorScheme.error,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Section(
                  label: 'Secure Data Protection'.tr(),
                  child: (gap) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: gap),
                    child: Text(
                      'data_secure_desc'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textDisplayColor,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'GYS APP ${DateTime.now().year}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textColor?.withValues(alpha: .45),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
