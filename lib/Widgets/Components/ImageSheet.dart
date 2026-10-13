import 'dart:async';

import 'package:flutter/material.dart';

import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Logger.dart';
import '../../Utils/Function.dart';
import '../../Utils/Functions/CopyToClip.dart';
import '../../Utils/Functions/ImageActions.dart';
import '../../Utils/Functions/NavigateToScreen.dart';
import '../../Utils/Functions/SnackBar.dart';
import 'AppSheet.dart';
import 'CachedNetworkImage.dart';
import 'CustomBottomDialog.dart';
import 'SheetTile.dart';

void showImageSheet(
  BuildContext context, {
  required String? url,
  required String name,
  String? title,
}) {
  if (url == null || url.isEmpty || !url.startsWith('http')) return;
  final busy = false.live;

  Future<void> run(Future<void> Function() job) async {
    if (busy.value) return;
    busy.value = true;
    try {
      await job();
    } catch (e, st) {
      logError('ImageSheet', e, st);
      snackString(getString.imageActionFailed);
    } finally {
      busy.value = false;
    }
  }

  showCustomBottomDialog(
    context,
    Builder(
      builder: (sheet) => AppSheet(
        title: title ?? name,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: cachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 12),
            Watch(
              () => Column(
                children: [
                  SheetTile(
                    tinted: true,
                    radius: groupedRadius(0, 4),
                    enabled: !busy.value,
                    leading: busy.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download_rounded),
                    title: Text(getString.imageSave),
                    onTap: () => unawaited(
                      run(() async {
                        final file = await saveImage(url, name: name);
                        snackString(
                          getString.imageSavedTo(file.path),
                          clipboard: file.path,
                        );
                        if (sheet.mounted) popPage(sheet);
                      }),
                    ),
                  ),
                  SheetTile(
                    tinted: true,
                    radius: groupedRadius(1, 4),
                    enabled: !busy.value,
                    leading: const Icon(Icons.share_rounded),
                    title: Text(getString.share),
                    onTap: () => unawaited(
                      run(() async {
                        final file = await downloadImage(url, name: name);
                        shareFile(file.path, name);
                      }),
                    ),
                  ),
                  SheetTile(
                    tinted: true,
                    radius: groupedRadius(2, 4),
                    leading: const Icon(Icons.link_rounded),
                    title: Text(getString.copyLink),
                    onTap: () {
                      copyToClipboard(url, message: getString.linkCopied);
                      popPage(sheet);
                    },
                  ),
                  SheetTile(
                    tinted: true,
                    radius: groupedRadius(3, 4),
                    leading: const Icon(Icons.open_in_browser_rounded),
                    title: Text(getString.openInBrowser),
                    onTap: () {
                      unawaited(openLinkInBrowser(url));
                      popPage(sheet);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
