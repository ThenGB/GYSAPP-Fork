import 'dart:async';
import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../data.dart';

class Mailer {
  final String username;
  final String password;
  final Completer initialization = Completer();
  late final SmtpServer smtpServer = gmail(username, password);

  late String template;

  Mailer(this.username, this.password) {
    rootBundle.loadString(Assets.assetsDataEmailReport).then((value) {
      template = value;
      initialization.complete();
    });
  }

  Future sendMessage(String text, String? fromEmail) async {
    await initialization.future;
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    var deviceInfo = await deviceInfoPlugin.deviceInfo;
    var deviceDataString = deviceInfo.data.entries
        .map((e) =>
            '<tr><td style="width: 40%;border: 1px solid black;">${e.key}</td><td style="border: 1px solid black;">${e.value}</td></tr>')
        .join();
    text +=
        '<br><br>Device Info:<br><table style="width:100%">$deviceDataString</table>';

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var packageInfoString = packageInfo.data.entries
        .map((e) =>
            '<tr><td style="width: 40%;border: 1px solid black;">${e.key}</td><td style="border: 1px solid black;">${e.value}</td></tr>')
        .join();
    text +=
        '<br><br>App Info:<br><table style="width:100%">$packageInfoString</table>';
    final Message message = Message()
      ..from = Address(username, 'E-GYS Mobile Reporting System')
      ..recipients.add(Address('gegasoleh@gmail.com', 'Programmer'))
      ..ccRecipients.add(Address(username))
      ..subject =
          'Email Report from "${fromEmail ?? 'Anonymous (unauthorized)'}"'
      ..html = template.replaceFirst('{{m3ss4g3}}', text);
    List<Map<String, dynamic>> additionalRecipients = [];
    try {
      var response = await AppConfigStore.listMapConfig('mailer_recipients')
          .timeout(Duration(seconds: 5));
      additionalRecipients.addAll(response);
    } catch (e) {
      log('Failed to fetch additional recipients');
    }
    for (var recipient in additionalRecipients) {
      message.ccRecipients
          .add(Address(recipient['address'], recipient['name']));
    }
    try {
      final sendReport = await send(message, smtpServer);
      log('Message sent: $sendReport');
    } on MailerException catch (e) {
      log('Message not sent.');
      for (var p in e.problems) {
        log('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}

