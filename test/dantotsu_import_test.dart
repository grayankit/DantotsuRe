import 'dart:convert';

import 'package:dartotsu/Core/Preferences/DantotsuImport.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('password is padded to 16 characters with zeros', () {
    expect(DantotsuBackup.keyPassword('2006'), '2006000000000000');
    expect(DantotsuBackup.keyPassword(' 2006 '), '2006000000000000');
    expect(DantotsuBackup.keyPassword('a' * 20), 'a' * 16);
  });

  test('encrypted backups round trip', () async {
    const text =
        '{"General":{"CheckUpdate":{"type":"kotlin.Boolean","value":true}}}';
    final bytes = await DantotsuBackup.encrypt(
      text,
      '2006',
      List.filled(16, 7),
    );
    expect(await DantotsuBackup.decrypt(bytes, '2006'), text);
    await expectLater(DantotsuBackup.decrypt(bytes, '1234'), throwsA(anything));
  });

  test('values are unwrapped by type', () {
    final b = DantotsuBackup.parse(
      jsonEncode({
        'General': {
          'CheckUpdate': {'type': 'kotlin.Boolean', 'value': true},
          'AnimeExtensionRepos': {
            'type': 'java.util.HashSet',
            'value': ['https://a.test/index.json', 'junk'],
          },
        },
      }),
    );
    expect(b.get<bool>('General', 'CheckUpdate'), true);
    expect(b.get<int>('General', 'CheckUpdate'), isNull);
    expect(b.urls('AnimeExtensionRepos'), ['https://a.test/index.json']);
  });

  test('conversions', () {
    expect(dantotsuSpeed(5, cursed: false), 1.0);
    expect(dantotsuSpeed(4, cursed: true), 2.0);
    expect(dantotsuSpeed(99, cursed: false), isNull);
    expect(dantotsuMinutes(2, dantotsuActivityMinutes), 60);
    expect(dantotsuMinutes(-1, dantotsuActivityMinutes), isNull);
    expect(dantotsuColor(-16738680), 0xFF009688);
    expect(dantotsuDns(0), isNull);
    expect(dantotsuDns(1), '');
    expect(dantotsuDns(2), contains('dns.google'));
  });
}
