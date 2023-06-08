import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../../../data/utilities/enums.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../data/utilities/extensions/datetime_ext.dart';
import '../../../router/router.dart';
import '../../presentations.dart';

@RoutePage()
class BibleNoteListView extends StatelessWidget {
  final BibleCubit cubit;
  const BibleNoteListView({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<BibleCubit, BibleState>(
        builder: (context, state) => Scaffold(
          backgroundColor: context.colorScheme.background,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notes'.tr()),
                Text(
                  '${state.notes.length} ${'notes saved'.tr()}',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          body: ListView.builder(
            itemCount: state.notes.length,
            itemBuilder: (context, index) {
              var item = state.notes[index];
              return Material(
                child: InkWell(
                  onTap: () {
                    router.push(BibleNoteRoute(
                      initialData: item,
                      cubit: cubit,
                      mode: BibleNoteMode.viewOnly,
                      onSave: (data) {
                        context.read<BibleCubit>().saveNote(data);
                        router.pop();
                        // router.push(BibleNoteListRoute(cubit: context.read()));
                      },
                    ));
                  },
                  child: FutureBuilder(
                    future: cubit.getBibleTitle(item.verses, withVerse: true),
                    builder: (context, snapshot) => Column(
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      snapshot.data ?? 'Loading...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    item.createdDate.toHumanDate(),
                                    style: context.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                quill.Document.fromJson(jsonDecode(item.text!))
                                    .toPlainText()
                                    .trim()
                                    .replaceAll('\n', ' .. '),
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          indent: 16,
                          endIndent: 16,
                          height: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
