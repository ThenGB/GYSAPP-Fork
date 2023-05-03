import 'package:flutter/material.dart';

import '../../../components/widgets/section.dart';

class BibleGreeting extends StatelessWidget {
  final Function(BuildContext context) onTapSelectBible;
  const BibleGreeting({super.key, required this.onTapSelectBible});

  @override
  Widget build(BuildContext context) {
    return Section(
      label: 'Greetings',
      child: (gap) => SingleChildScrollView(
          padding: EdgeInsets.all(gap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Welcome to bible',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'To start, select bible code from the menu',
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                onPressed: () async {
                  onTapSelectBible(context);
                },
                child: const Text('Select bible'),
              ),
            ],
          )),
    );
  }
}
