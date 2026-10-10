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
    if (left.inHours >= 1) return '${left.inHours} h';
    return '${left.inMinutes.clamp(0, 59)} min';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return AppSheet(
      title: widget.source.name,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          Dimens.gapSm,
          0,
          Dimens.gapSm,
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
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SheetTile(
                leading: const Icon(Icons.tune_rounded),
                title: Text(getString.watchSourceSettings),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => navigateToPage<void>(
                  context,
                  SourcePreferenceScreen(source: widget.source),
                ),
              ),
              if (h.url != null)
                SheetTile(
                  leading: const Icon(Icons.public_rounded),
                  title: Text(getString.watchOpenWebView),
                  subtitle: Text(getString.watchOpenWebViewDesc),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _openWebView,
                ),
              if (h.url != null) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    Dimens.gap,
                    Dimens.gapSm,
                    Dimens.gap,
                    Dimens.gapSm,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: Dimens.borderSm,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(Dimens.gap),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _line(
                            context,
                            Icons.cookie_outlined,
                            getString.watchCookieCount(h.cookies, h.host),
                          ),
                          _line(
                            context,
                            h.clearance == null
                                ? Icons.shield_outlined
                                : Icons.verified_user_rounded,
                            h.clearance == null
                                ? getString.watchClearanceMissing
                                : getString.watchClearanceActive(
                                    _until(h.clearance!.expires),
                                  ),
                            color: h.clearance == null ? null : scheme.primary,
                          ),
                          _line(
                            context,
                            Icons.badge_outlined,
                            h.customAgent
                                ? getString.watchAgentCustom
                                : getString.watchAgentShared,
                            color: h.customAgent ? scheme.error : null,
                          ),
                          if (result != null)
                            _line(
                              context,
                              result.$1 == ProbeResult.ok
                                  ? Icons.check_circle_rounded
                                  : Icons.error_outline_rounded,
                              switch (result.$1) {
                                ProbeResult.ok => getString.watchProbeOk(
                                  result.$2 ?? 0,
                                ),
                                ProbeResult.challenge =>
                                  getString.watchProbeChallenge,
                                ProbeResult.blocked =>
                                  getString.watchProbeBlocked(result.$2 ?? 0),
                                ProbeResult.failed =>
                                  getString.watchProbeFailed,
                              },
                              color: result.$1 == ProbeResult.ok
                                  ? scheme.primary
                                  : scheme.error,
                            ),
                          SizedBox(height: Dimens.gapSm),
                          Row(
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: busy ? null : _test,
                                icon: busy
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.network_check_rounded),
                                label: Text(getString.watchTestConnection),
                              ),
                              SizedBox(width: Dimens.gapSm),
                              if (blocked)
                                FilledButton.icon(
                                  onPressed: _openWebView,
                                  icon: const Icon(Icons.public_rounded),
                                  label: Text(getString.watchSolveChallenge),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SheetTile(
                  leading: const Icon(Icons.delete_sweep_rounded),
                  title: Text(getString.watchClearCookies),
                  onTap: _clear,
                ),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _line(
    BuildContext context,
    IconData icon,
    String text, {
    Color? color,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: color ?? context.colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: Dimens.gapSm),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    ),
  );
}
