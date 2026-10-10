import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';

import '../NetworkManager/CookieManager.dart';
import '../NetworkManager/NetworkManager.dart';
import '../State/State.dart';

enum ProbeResult { ok, challenge, blocked, failed }

class SourceHealth {
  final String? url;
  final String host;
  final int cookies;
  final StoredCookie? clearance;
  final String userAgent;
  final bool customAgent;

  const SourceHealth({
    required this.url,
    required this.host,
    required this.cookies,
    required this.clearance,
    required this.userAgent,
    required this.customAgent,
  });

  static SourceHealth read(Source source) {
    final net = find<NetworkManager>();
    final url = source.baseUrl?.trim();
    final uri = url == null || url.isEmpty ? null : Uri.tryParse(url);
    final host = uri?.host ?? '';
    final jar = host.isEmpty
        ? const <StoredCookie>[]
        : net.cookieManager
              .getCookiesForDomain(host)
              .where((c) => !c.isExpired)
              .toList();
    final clearance = jar.where((c) => c.name == 'cf_clearance').firstOrNull;
    return SourceHealth(
      url: uri == null ? null : url,
      host: host,
      cookies: jar.length,
      clearance: clearance,
      userAgent: net.userAgent,
      customAgent: net.userAgent != net.defaultUserAgent,
    );
  }

  static Future<(ProbeResult, int?)> probe(Source source) async {
    final url = source.baseUrl?.trim();
    if (url == null || url.isEmpty) return (ProbeResult.failed, null);
    try {
      final res = await find<NetworkManager>().get(url, decodeJson: false);
      final mitigated = res.headers.entries.any(
        (e) => e.key.toLowerCase() == 'cf-mitigated',
      );
      final body = res.data is String ? res.data as String : '';
      final challenge =
          mitigated ||
          body.contains('Just a moment') ||
          body.contains('challenge-platform');
      if (res.statusCode < 400 && !challenge) {
        return (ProbeResult.ok, res.statusCode);
      }
      if (challenge) return (ProbeResult.challenge, res.statusCode);
      if (res.statusCode == 403 || res.statusCode == 429) {
        return (ProbeResult.blocked, res.statusCode);
      }
      return (ProbeResult.failed, res.statusCode);
    } catch (_) {
      return (ProbeResult.failed, null);
    }
  }
}
