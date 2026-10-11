import 'package:flutter/material.dart';

import '../../../../Core/Watch/EpisodeUnits.dart';
import '../../../../Utils/Extensions/Responsive.dart';
import '../../../../Widgets/Components/ScrollReveal.dart';

class UnitLayout extends StatelessWidget {
  final List<WatchUnit> units;
  final int view;
  final Widget Function(WatchUnit unit) builder;

  const UnitLayout({
    super.key,
    required this.units,
    required this.view,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (view == 0) {
      return Column(
        children: [
          for (final (i, u) in units.indexed)
            Padding(
              padding: EdgeInsets.only(bottom: Dimens.gapSm),
              child: ScrollReveal(delay: 30 * (i % 6), child: builder(u)),
            ),
        ],
      );
    }
    return LayoutBuilder(
      builder: (context, box) {
        final gap = Dimens.gapSm;
        final target = view == 1 ? 190.0 : 64.0;
        final columns = (box.maxWidth / target).floor().clamp(
          view == 1 ? 2 : 4,
          16,
        );
        final width = (box.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (i, u) in units.indexed)
              SizedBox(
                width: width,
                height: view == 2 ? 48 : null,
                child: ScrollReveal(delay: 30 * (i % 6), child: builder(u)),
              ),
          ],
        );
      },
    );
  }
}
