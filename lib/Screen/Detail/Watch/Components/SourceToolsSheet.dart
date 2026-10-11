import 'dart:async';

import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/material.dart';

import '../../../../Core/NetworkManager/NetworkManager.dart';
import '../../../../Core/State/State.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../../Core/Watch/SourceHealth.dart';
import '../../../../Utils/Extensions/ContextExtensions.dart';
import '../../../../Utils/Extensions/Responsive.dart';
import '../../../../Utils/Functions/NavigateToScreen.dart';
import '../../../../Utils/Functions/SnackBar.dart';
import '../../../../Widgets/Components/AppSheet.dart';
import '../../../../Widgets/Components/SheetTile.dart';
import '../../../Extension/SourcePreferenceScreen.dart';
import '../../../Webview/WebView.dart';

class SourceToolsSheet extends StatefulWidget {
  final Source source;

  const SourceToolsSheet({super.key, required this.source});

  @override
  State<SourceToolsSheet> createState() => _SourceToolsSheetState();
}

class _SourceToolsSheetState extends State<SourceToolsSheet> {
  late final health = SourceHealth.read(widget.source).live;
  final probe = Live<(ProbeResult, int?)?>(null);
  final probing = false.live;

  void _refresh() => health.value = SourceHealth.read(widget.source);

  Future<void> _openWebView() async {
    final url = health.value.url;
    if (url == null) return;
    await navigateToPage<void>(context, WebView(url: url));
    if (!mounted) return;
    _refresh();
    unawaited(_test());
  }

  Future<void> _test() async {
    probing.value = true;
    final result = await SourceHealth.probe(widget.source);
    if (!mounted) return;
    probe.value = result;
    probing.value = false;
    _refresh();
  }

  Future<void> _clear() async {
    final host = health.value.host;
    if (host.isEmpty) return;
    await find<NetworkManager>().cookieManager.deleteCookiesForDomain(host);
    if (!mounted) return;
    probe.value = null;
    _refresh();
    snackString(getString.watchCookiesCleared);
  }

  String _until(DateTime? date) {
    if (date == null) return getString.watchClearanceSession;
    final left = date.difference(DateTime.now());
    if (left.inHours >= 1) return '${left.inHours} h left';
    return '${left.inMinutes.clamp(0, 59)} min left';
  }

  BorderRadius _group(int i, int count) => BorderRadius.vertical(
    top: Radius.circular(i == 0 ? 20 : 6),
    bottom: Radius.circular(i == count - 1 ? 20 : 6),
  );

  Widget _badge(
    BuildContext context,
    IconData icon, {
    Color? background,
    Color? foreground,
    double size = 40,
  }) {
    final scheme = context.colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? scheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: foreground ?? scheme.onPrimaryContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return AppSheet(
      title: widget.source.name,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          Dimens.pagePad,
          0,
          Dimens.pagePad,
          Dimens.gapLg,
        ),
        child: Watch(() {
          final h = health.value;
          final result = probe.value;
          final busy = probing.value;
          final blocked =
              result != null &&
              (result.$1 == ProbeResult.challenge ||
                  result.$1 == ProbeResult.blocked);
          final hasWeb = h.url != null;
          final rows = <Widget Function(BorderRadius)>[
            (r) => SheetTile(
              tinted: true,
              radius: r,
              leading: _badge(context, Icons.tune_rounded),
              title: Text(getString.watchSourceSettings),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => navigateToPage<void>(
                context,
                SourcePreferenceScreen(source: widget.source),
              ),
            ),
            if (hasWeb)
              (r) => SheetTile(
                tinted: true,
                radius: r,
                leading: _badge(context, Icons.public_rounded),
                title: Text(getString.watchOpenWebView),
                subtitle: Text(getString.watchOpenWebViewDesc),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _openWebView,
              ),
          ];
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, row) in rows.indexed) ...[
                row(_group(i, rows.length)),
                const SizedBox(height: 2),
              ],
              if (hasWeb) ...[
                SizedBox(height: Dimens.gap),
                _status(context, h, result, busy, blocked),
                SizedBox(height: Dimens.gap),
                SheetTile(
                  tinted: true,
                  radius: BorderRadius.circular(20),
                  leading: _badge(
                    context,
                    Icons.delete_sweep_rounded,
                    background: scheme.errorContainer,
                    foreground: scheme.onErrorContainer,
                  ),
                  title: Text(
                    getString.watchClearCookies,
                    style: TextStyle(color: scheme.error),
                  ),
                  onTap: _clear,
                ),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _status(
    BuildContext context,
    SourceHealth h,
    (ProbeResult, int?)? result,
    bool busy,
    bool blocked,
  ) {
    final scheme = context.colorScheme;
    final lines = <(IconData, String, _Tone)>[
      (
        Icons.cookie_outlined,
        getString.watchCookieCount(h.cookies, h.host),
        h.cookies > 0 ? _Tone.neutral : _Tone.muted,
      ),
      (
        h.clearance == null
            ? Icons.shield_outlined
            : Icons.verified_user_rounded,
        h.clearance == null
            ? getString.watchClearanceMissing
            : getString.watchClearanceActive(_until(h.clearance!.expires)),
        h.clearance == null ? _Tone.muted : _Tone.good,
      ),
      (
        Icons.badge_outlined,
        h.customAgent ? getString.watchAgentCustom : getString.watchAgentShared,
        h.customAgent ? _Tone.bad : _Tone.muted,
      ),
      if (result != null)
        (
          result.$1 == ProbeResult.ok
              ? Icons.check_circle_rounded
              : Icons.error_outline_rounded,
          switch (result.$1) {
            ProbeResult.ok => getString.watchProbeOk(result.$2 ?? 0),
            ProbeResult.challenge => getString.watchProbeChallenge,
            ProbeResult.blocked => getString.watchProbeBlocked(result.$2 ?? 0),
            ProbeResult.failed => getString.watchProbeFailed,
          },
          result.$1 == ProbeResult.ok ? _Tone.good : _Tone.bad,
        ),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: blocked
            ? scheme.errorContainer.withValues(alpha: 0.35)
            : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: EdgeInsets.all(Dimens.gap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (icon, text, tone) in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _badge(
                      context,
                      icon,
                      size: 32,
                      background: switch (tone) {
                        _Tone.good => scheme.primaryContainer,
                        _Tone.bad => scheme.errorContainer,
                        _ => scheme.surfaceContainerHighest,
                      },
                      foreground: switch (tone) {
                        _Tone.good => scheme.onPrimaryContainer,
                        _Tone.bad => scheme.onErrorContainer,
                        _ => scheme.onSurfaceVariant,
                      },
                    ),
                    SizedBox(width: Dimens.gapSm),
                    Expanded(
                      child: Text(
                        text,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: tone == _Tone.bad
                              ? scheme.onErrorContainer
                              : scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: Dimens.gapXs),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: busy ? null : _test,
                    icon: busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.network_check_rounded),
                    label: Text(getString.watchTestConnection),
                  ),
                ),
                if (blocked) ...[
                  SizedBox(width: Dimens.gapSm),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _openWebView,
                      icon: const Icon(Icons.public_rounded),
                      label: Text(getString.watchSolveChallenge),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _Tone { good, bad, neutral, muted }
