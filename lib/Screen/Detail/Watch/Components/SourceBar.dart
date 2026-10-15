import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/material.dart';
import '../../../../Widgets/Components/ThemedContainer.dart';

import '../../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../../Utils/Extensions/ContextExtensions.dart';
import '../../../../Utils/Extensions/Responsive.dart';
import '../../../../Widgets/Components/CachedNetworkImage.dart';
import '../../../../Widgets/Components/Clickable.dart';

class SourceBar extends StatelessWidget {
  final Source? source;
  final String status;
  final bool busy;
  final bool canFix;
  final VoidCallback onPick;
  final VoidCallback onWrongTitle;
  final VoidCallback onReset;
  final VoidCallback onTools;
  final bool selectable;

  const SourceBar({
    super.key,
    required this.source,
    required this.status,
    required this.busy,
    required this.canFix,
    required this.onPick,
    required this.onWrongTitle,
    required this.onReset,
    required this.onTools,
    this.selectable = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Clickable(
                onTap: selectable ? onPick : null,
                child: ThemedContainer(
                  blur: false,
                  color: scheme.surfaceContainerHigh,
                  borderRadius: Dimens.borderSm,
                  padding: EdgeInsets.zero,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimens.gap,
                      vertical: Dimens.gapSm,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: cachedNetworkImage(
                              imageUrl: source?.iconUrl,
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Icon(
                                Icons.extension_rounded,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: Dimens.gap),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                source?.name ?? getString.watchSource,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if ((source?.lang ?? '').isNotEmpty)
                                Text(
                                  source!.lang!.toUpperCase(),
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (selectable)
                          Icon(
                            Icons.unfold_more_rounded,
                            color: scheme.onSurfaceVariant,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: Dimens.gapSm),
            IconButton.filledTonal(
              tooltip: getString.watchSourceTools,
              onPressed: onTools,
              icon: const Icon(Icons.settings_rounded),
            ),
          ],
        ),
        SizedBox(height: Dimens.gapSm),
        Row(
          children: [
            if (busy)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.primary,
                  ),
                ),
              ),
            Expanded(
              child: Text(
                status,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            if (canFix && selectable) ...[
              TextButton(
                onPressed: onReset,
                child: Text(getString.watchSearchAgain),
              ),
              TextButton(
                onPressed: onWrongTitle,
                child: Text(getString.watchWrongTitle),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
