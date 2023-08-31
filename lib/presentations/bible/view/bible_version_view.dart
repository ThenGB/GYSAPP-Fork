// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
// ignore: implementation_imports
import 'package:ftpconnect/src/ftp_entry.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/data.dart';
import '../../../di/injection.dart';
import '../../presentations.dart';

@RoutePage()
class BibleVersionView extends StatefulWidget {
  final DashboardCubit dashboardCubit;
  const BibleVersionView({super.key, required this.dashboardCubit});

  @override
  State<BibleVersionView> createState() => _BibleVersionViewState();
}

class _BibleVersionViewState extends State<BibleVersionView> {
  List<FTPEntry>? initialData;

  Map<String, Function()> callbacks = {};

  ValueNotifier<bool> isSyncing = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.dashboardCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Version'.tr()),
          actions: [
            ValueListenableBuilder(
              valueListenable: isSyncing,
              builder: (context, value, child) => Tooltip(
                message: 'One click to sync all downloaded version'.tr(),
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.withOpacity(.1),
                    surfaceTintColor: Colors.transparent,
                  ),
                  onPressed: value
                      ? null
                      : () async {
                          isSyncing.value = true;
                          for (var callback in callbacks.values) {
                            await callback();
                          }
                          isSyncing.value = false;
                        },
                  child: Text(value ? 'Syncing...'.tr() : 'Sync'.tr()),
                ),
              ),
            ),
            SizedBox(
              width: 16,
            ),
          ],
        ),
        body: Container(
          color: context.colorScheme.background,
          child: FutureBuilder(
            initialData: initialData,
            future:
                widget.dashboardCubit.listNetworkBibles(initialData != null),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done &&
                  initialData == null) {
                return Shimmer.fromColors(
                  period: Duration(milliseconds: 500),
                  baseColor: context.theme.disabledColor.withOpacity(.1),
                  highlightColor: context.theme.disabledColor.withOpacity(.2),
                  child: ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.green,
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    CupertinoIcons.checkmark_seal_fill,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  // SizedBox(
                                  //   width: 4,
                                  // ),
                                  // Text(
                                  //   'Syncronized'.tr(),
                                  //   style: TextStyle(
                                  //     fontWeight: FontWeight.bold,
                                  //     fontSize: 10,
                                  //     color: Colors.white,
                                  //   ),
                                  // )
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Chinese Union Version',
                                  style: TextStyle(
                                      fontFamily: 'FlowCircular',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                width: 100,
                                height: 32,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                width: 32,
                                height: 32,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '5.56 MB・Updated at 28 09 2023',
                          style: TextStyle(
                            fontFamily: 'FlowCircular',
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              if (snapshot.hasError && initialData == null) {
                return Center(
                  child: NoDataFound(
                      action: ElevatedButton(
                          onPressed: () {
                            setState(() {});
                          },
                          child: Text('Reload')),
                      title: 'Error',
                      description: snapshot.error.toString()),
                );
              }
              initialData = snapshot.data;

              return ListView.builder(
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (context, index) {
                  var item = snapshot.data![index];
                  AppDirectory localDir = di();
                  var localFile = File('${localDir.bibleFolder}/${item.name}');
                  var difference = item.modifyTime
                          ?.difference(
                            widget.dashboardCubit.state.lastSync[item.name] ??
                                item.modifyTime ??
                                DateTime.now(),
                          )
                          .inMinutes ??
                      0;
                  bool isExist = localFile.existsSync();
                  bool isSyncronized =
                      (difference.isNegative || difference == 0) && isExist;
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isSyncronized)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.green,
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.checkmark_seal_fill,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  '・${item.size?.fromSizeToBytes() ?? '∞'}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                getBibleCodeName(item.name),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: SyncButton(
                      localFile: localFile,
                      cubit: widget.dashboardCubit,
                      item: item,
                      isSyncronized: isSyncronized,
                      downloadCallback: (callback) {
                        callbacks[localFile.path] = callback;
                      },
                    ),
                    subtitle: Text(
                      '${'Updated at'.tr()} ${DateFormat('HH:mm | dd MMM yyyy', context.locale.languageCode).format((item.modifyTime ?? DateTime.now()).toLocal())}',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class SyncButton extends StatefulWidget {
  const SyncButton({
    super.key,
    required this.localFile,
    required this.cubit,
    required this.item,
    required this.isSyncronized,
    required this.downloadCallback,
  });

  final File localFile;
  final DashboardCubit cubit;
  final FTPEntry item;
  final bool isSyncronized;
  final Function(Function() callback) downloadCallback;
  @override
  State<SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends State<SyncButton> {
  GlobalKey buttonKey = GlobalKey();
  ValueNotifier<double> widgetWidth = ValueNotifier(1);
  ValueNotifier<double> widgetHeight = ValueNotifier(1);
  ValueNotifier<double?> downloadProgress = ValueNotifier(null);
  int fileSize = 0;
  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widgetWidth.value = buttonKey.currentContext!.size!.width;
      widgetHeight.value = buttonKey.currentContext!.size!.height;
    });
    super.didChangeDependencies();
  }

  @override
  void initState() {
    if (widget.isSyncronized) {
      widget.downloadCallback(downloadCallback);
    }
    super.initState();
  }

  @override
  void dispose() {
    widgetWidth.dispose();
    widgetHeight.dispose();
    downloadProgress.dispose();
    super.dispose();
  }

  bool isDownloading = false;

  downloadCallback() async {
    downloadProgress.value = null;
    if (!widget.localFile.existsSync()) {
      // continue;
      widget.localFile.createSync(
          recursive: true); // diubah, karena tidak download otomatis lagi
    }
    setState(() {
      isDownloading = true;
    });
    var downloaded = await widget.cubit.downloadBible(
      widget.item.name,
      widget.localFile,
      (progressInPercent, totalReceived, totalSize) {
        log('progressinpercent $progressInPercent');
        downloadProgress.value = progressInPercent / 100;
        fileSize = totalSize;
      },
    );
    setState(() {
      isDownloading = false;
    });
    if (!downloaded) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(msg: 'Syncronize failed'.tr());
      widget.localFile.deleteSync();
    } else {
      Fluttertoast.cancel();
      Fluttertoast.showToast(msg: 'Syncronized'.tr());
    }
    Future.delayed(
      Duration(milliseconds: 300),
      () {
        context
            .findAncestorStateOfType<_BibleVersionViewState>()
            ?.setState(() {});
        widget.downloadCallback(downloadCallback);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isDownloading) {
          widget.cubit.ftp!.disconnect();
        }
        return true;
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ValueListenableBuilder(
                valueListenable: downloadProgress,
                builder: (context, progress, child) => ValueListenableBuilder(
                  valueListenable: widgetHeight,
                  builder: (context, widgetHeight, child) =>
                      ValueListenableBuilder(
                    valueListenable: widgetWidth,
                    builder: (context, widgetWidth, child) => ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: SizedBox(
                          width: widgetWidth,
                          height: widgetHeight,
                          child: Visibility(
                            visible: isDownloading,
                            child: Stack(
                              children: [
                                // LinearProgressIndicator(
                                //   minHeight: widgetHeight,
                                //   value: progress,
                                // ),
                                Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 4,
                                    value: progress,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      '${(fileSize * (progress ?? 0)).toInt().fromSizeToBytes()}\n(${((progress ?? 0) * 100).toInt()}%)',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 5,
                                      )),
                                )
                              ],
                            ),
                          )),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: !isDownloading,
                child: Checkbox(
                  key: buttonKey,
                  value: widget.isSyncronized,
                  onChanged:
                      widget.item.name.contains('b_tb') && widget.isSyncronized
                          ? null
                          : (isSyncronized) async {
                              if (!isSyncronized!) {
                                if (await context.showConfirmation(
                                    'Are you sure want to delete this version from your local cache?'
                                        .tr())) {
                                  widget.localFile.deleteSync();
                                  Future.delayed(
                                    Duration(milliseconds: 300),
                                    () {
                                      context
                                          .findAncestorStateOfType<
                                              _BibleVersionViewState>()
                                          ?.setState(() {});
                                    },
                                  );
                                }
                              } else {
                                downloadCallback();
                              }
                            },
                ),
              ),
            ],
          ),
          // if (widget.isSyncronized && !widget.item.name.contains('b_tb'))
          //   IconButton.filledTonal(
          //     style: IconButton.styleFrom(
          //       backgroundColor: Colors.amber.shade100,
          //       foregroundColor: Colors.red,
          //       disabledBackgroundColor: Colors.green,
          //       disabledForegroundColor: Colors.white,
          //     ),
          //     onPressed: isDownloading
          //         ? null
          //         : () async {
          //             if (await context.showConfirmation(
          //                 'Are you sure want to delete this version from your local cache?'
          //                     .tr())) {
          //               widget.localFile.deleteSync();
          //               Future.delayed(
          //                 Duration(milliseconds: 300),
          //                 () {
          //                   context
          //                       .findAncestorStateOfType<
          //                           _BibleVersionViewState>()
          //                       ?.setState(() {});
          //                 },
          //               );
          //             }
          //           },
          //     icon: CustomAnimationBuilder(
          //       control: isDownloading ? Control.mirror : Control.stop,
          //       duration: kThemeAnimationDuration,
          //       tween: Tween<double>(begin: -1, end: 1),
          //       builder: (context, value, child) => Transform.translate(
          //         offset: Offset(0, isDownloading ? 2 * value : 0),
          //         child: CrossFade<bool>(
          //           duration: Duration(milliseconds: 300),
          //           value: isDownloading,
          //           builder: (context, isDownloading) => Icon(isDownloading
          //               ? Icons.arrow_circle_down_rounded
          //               : CupertinoIcons.trash_circle_fill),
          //         ),
          //       ),
          //     ),
          //   )
        ],
      ),
    );
  }
}
