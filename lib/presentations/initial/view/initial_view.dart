import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../../router/router.dart';
import '../bloc/initial_cubit.dart';

@RoutePage()
class InitialView extends StatelessWidget {
  const InitialView({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<InitialCubit>().initState();
    return BlocBuilder<InitialCubit, InitialState>(
      builder: (context, state) => BlocListener<InitialCubit, InitialState>(
        listener: (context, state) {
          if (state.isLoaded) {
            router.popUntilRoot();
            router.replace(
              const DashboardRoute(),
            );
          }
        },
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(),
                ),
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(children: [
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: LoopAnimationBuilder(
                          duration: const Duration(milliseconds: 500),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          child: const Icon(
                            Icons.sync,
                            size: 16,
                          ),
                          builder: (context, value, child) => state.isFailed
                              ? child!
                              : Transform.rotate(
                                  angle: -(value * 2 * 3.1415),
                                  child: child,
                                ),
                        ),
                      ),
                    ),
                    TextSpan(
                      text: state.message,
                    ),
                  ]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
