import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/utilities/extensions/context_ext.dart';
import '../../../domain/entity/verse/verse.dart';
import '../../faith/view/faith_note_list_view.dart';
import '../../presentations.dart';

@RoutePage()
class BibleSearchView extends StatefulWidget {
  const BibleSearchView({super.key, required this.cubit, required this.onTap});
  final BibleCubit cubit;
  final Function(Verse item) onTap;

  @override
  State<BibleSearchView> createState() => _BibleSearchViewState();
}

class _BibleSearchViewState extends State<BibleSearchView> {
  late final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: BlocBuilder<BibleCubit, BibleState>(
        builder: (context, state) => Scaffold(
          backgroundColor: context.colorScheme.background,
          appBar: AppBar(
            title: Text('Search verses'.tr()),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: context.theme.disabledColor)),
                    isDense: true,
                    hintText: 'Search verses'.tr(),
                  ),
                ),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: searchController,
                  builder: (context, child) => FutureBuilder(
                    future:
                        widget.cubit.searchBibleByString(searchController.text),
                    builder: (context, snapshot) => (!snapshot.hasData ||
                            snapshot.data?.isEmpty == true)
                        ? searchController.text.isEmpty
                            ? NoDataFound(
                                title: 'Search terms to start'.tr(),
                                description:
                                    'Make sure your spellings is correct'.tr())
                            : NoDataFound(
                                title: '"${searchController.text}" not found',
                                description:
                                    'Correct your spellings or search another terms'
                                        .tr())
                        : ListView.builder(
                            itemBuilder: (context, index) {
                              var item = snapshot.data![index];
                              return Column(
                                children: [
                                  Divider(height: 1),
                                  ListTile(
                                    onTap: () {},
                                    title: FutureBuilder(
                                      future: widget.cubit.getBibleTitle([item],
                                          withVerse: true),
                                      builder: (context, snapshot) => Text.rich(
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                          TextSpan(children: [
                                            TextSpan(
                                                text: snapshot.data ??
                                                    'Loading...'.tr(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                )),
                                            TextSpan(text: ' : '),
                                            buildHighlightedText(
                                              item.verse ?? '',
                                              searchController.text.split(' '),
                                              context,
                                            )
                                          ])),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
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
