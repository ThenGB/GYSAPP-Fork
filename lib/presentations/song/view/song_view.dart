import 'package:auto_route/auto_route.dart';
import 'package:church/data/utilities/extensions/context_ext.dart';
import 'package:church/data/utilities/variables/assets.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SongView extends StatelessWidget {
  const SongView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 56,
        titleSpacing: 0,
        leading: Center(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: context.theme.disabledColor),
              shape: BoxShape.circle,
              color: context.theme.canvasColor,
            ),
            child: Icon(
              Icons.home,
              color: context.theme.disabledColor,
            ),
          ),
        ),
        title: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      strokeAlign: BorderSide.strokeAlignCenter,
                      width: 1,
                      color: context.theme.disabledColor,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(100),
                      ),
                    )),
                onPressed: () {},
                child: const Text('002'),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      strokeAlign: BorderSide.strokeAlignCenter,
                      width: 1,
                      color: context.theme.disabledColor,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(100),
                      ),
                    )),
                onPressed: () {},
                child: const Text('KR'),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            visualDensity: VisualDensity.compact,
            icon: ColorFiltered(
              colorFilter: ColorFilter.mode(
                  context.theme.disabledColor, BlendMode.srcIn),
              child: Image.asset(
                Assets.assetsIconsNote,
                width: 24,
                height: 24,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert_rounded,
              color: context.theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}
