import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../components/components.dart';
import '../../../data/data.dart';
import '../../../di/injection.dart';
import '../../../domain/entity/entities.dart';
import '../../../router/router.dart';

@RoutePage()
class ReportView extends StatefulWidget {
  final Account? account;
  final Future<Account?> Function(String token) onLoggedIn;
  const ReportView({super.key, this.account, required this.onLoggedIn});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  late Account? account = widget.account;
  late TextEditingController messageController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool sendAsAnonymous = false;

  @override
  void dispose() {
    messageController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  bool isSending = false;

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
      floatingActionButton: FloatingActionButton(
        backgroundColor: context.colorScheme.primary,
        foregroundColor: context.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onPressed: isSending
            ? null
            : () async {
                try {
                  if (messageController.text.isEmpty) {
                    Fluttertoast.cancel();
                    Fluttertoast.showToast(
                      msg: 'Please fill the message box'.tr(),
                    );
                  }
                  setState(() {
                    isSending = true;
                  });
                  var mailer = await di.getAsync<Mailer>();
                  if (mailer.username.isEmpty) {
                    Fluttertoast.cancel();
                    Fluttertoast.showToast(
                      msg: 'Reporting system not available currently'.tr(),
                    );
                    setState(() {
                      isSending = false;
                    });
                    return;
                  }
                  await mailer
                      .sendMessage(
                        messageController.text,
                        sendAsAnonymous
                            ? 'Anonymous (Authorized)'
                            : account?.email,
                      )
                      .timeout(Duration(seconds: 10));
                  Clipboard.setData(
                    ClipboardData(text: messageController.text),
                  );
                  setState(() {
                    isSending = false;
                  });
                  messageController.text = '';
                  Fluttertoast.cancel();
                  Fluttertoast.showToast(msg: 'Email sent'.tr());
                  Fluttertoast.showToast(
                    msg: 'Your message copied to your clipboard!',
                  );
                } catch (e) {
                  Fluttertoast.cancel();
                  Fluttertoast.showToast(
                    msg: e is TimeoutException
                        ? 'Connection timeout'
                        : e.toString(),
                  );
                  setState(() {
                    isSending = false;
                  });
                }
              },
        child: isSending
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    context.colorScheme.onPrimary,
                  ),
                ),
              )
            : Icon(Icons.send),
      ),
      body: GestureDetector(
        onTap: () {
          if (focusNode.hasFocus) {
            FocusManager.instance.primaryFocus!.unfocus();
          } else {
            focusNode.requestFocus();
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 56),
          child: Card(
            child: Section(
              label: '${'How it works'.tr()} :',
              child: (gap) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: gap),
                    child: Text(
                      "To report any issues or provide suggestions, tap the 'Report' button located in the app's menu or on a designated page. Describe the matter in the provided text box and include relevant details, such as the page or action where the issue occurred. Tap 'Submit' to send your report to our team.\n\nYour feedback matters:\nYour reports help us improve the app's performance and user experience. We value your privacy, and your data is handled with utmost confidentiality.\n\nThank you for contributing to a better app experience!"
                          .tr(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(gap),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          style: context.textTheme.bodyMedium,
                          TextSpan(
                            text: '${'Account'.tr()} : ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: sendAsAnonymous
                                    ? 'Anonymous'.tr()
                                    : account?.email ?? 'Unknown'.tr(),
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              if (account == null)
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 2,
                                          horizontal: 4,
                                        ),
                                        textStyle: TextStyle(
                                          fontSize: 10,
                                          fontFamily: context
                                              .textTheme
                                              .bodyMedium
                                              ?.fontFamily,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      onPressed: () {
                                        router.push(
                                          LoginRoute(
                                            onLoggedIn: (token) async {
                                              account = await widget.onLoggedIn(
                                                token,
                                              );
                                              setState(() {});
                                            },
                                          ),
                                        );
                                      },
                                      child: Text('Login'.tr()),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (account == null)
                          Text(
                            'To receive our replies, kindly log in to your account.'
                                .tr(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        else
                          Row(
                            children: [
                              Checkbox(
                                value: sendAsAnonymous,
                                onChanged: (value) {
                                  setState(() {
                                    sendAsAnonymous = value!;
                                  });
                                },
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    sendAsAnonymous = !sendAsAnonymous;
                                  });
                                },
                                child: Text('Send as Anonymous'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(gap),
                    child: TextFormField(
                      enabled: !isSending,
                      controller: messageController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(gap),
                        alignLabelWithHint: true,
                        labelText: 'Your problem or suggestion'.tr(),
                        hintText: 'Write your problem or suggestion here'.tr(),
                      ),
                      minLines: 4,
                      maxLines: null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
