import 'package:auto_route/auto_route.dart';
import 'package:church/data/utilities/extensions/context_ext.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: context.colorScheme.background,
              ),
              child: Row(
                children: const [
                  CircleAvatar(),
                  SizedBox(
                    width: 12,
                  ),
                  Text('xTestx'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
