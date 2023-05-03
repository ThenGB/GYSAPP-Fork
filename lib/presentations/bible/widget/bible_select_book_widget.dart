import 'package:church/presentations/bible/cubit/bible_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BibleSelectBook extends StatelessWidget {
  const BibleSelectBook({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BibleCubit, BibleState>(
      builder: (context, state) => Scaffold(
        body: Column(
          children: [
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(4),
                crossAxisCount: 4,
                children: state.books
                    .map(
                      (e) => GestureDetector(
                        onTap: () {
                          context.read<BibleCubit>().selectBook(e);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          color: Colors.blue,
                          child: Center(
                            child: Text(
                              e.shortName ?? '-',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
