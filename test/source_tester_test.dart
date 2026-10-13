import 'package:dartotsu/Screen/Extension/Data/SourceTester.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('failureLogs keeps failures and drops the rest', () {
    final out = failureLogs([
      '[Bridge LOGS] [EXT] → GET https://a.example/x',
      '[Bridge LOGS] [EXT] ← 200 https://a.example/x (10ms)',
      '[Bridge LOGS] [EXT] × GET https://b.example/y (9ms)\njava.net.UnknownHostException: b.example',
      '[Bridge LOGS] [EXT] ← 403 https://c.example/z (5ms)',
      '[Bridge LOGS] [SIDECAR] Call failed: Exception: nope',
    ]);
    expect(out.contains('UnknownHostException'), isTrue);
    expect(out.contains('403'), isTrue);
    expect(out.contains('Call failed'), isTrue);
    expect(out.contains('← 200'), isFalse);
    expect(out.contains('→ GET'), isFalse);
  });

  test('failureLogs keeps only the newest entries past the cap', () {
    final lines = [for (var i = 0; i < 10; i++) 'failed $i'];
    final out = failureLogs(lines, max: 3).split('\n');
    expect(out, ['failed 7', 'failed 8', 'failed 9']);
  });
}
