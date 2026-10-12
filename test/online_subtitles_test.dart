import 'dart:io';

import 'package:dartotsu/Screen/Player/Engine/OnlineSubtitles.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('language names map to OpenSubtitles codes', () {
    expect(subtitleLanguageCode('English'), 'eng');
    expect(subtitleLanguageCode('german'), 'ger');
    expect(subtitleLanguageCode('por'), 'por');
    expect(subtitleLanguageCode('Klingon'), 'eng');
  });

  test('season is guessed from the title', () {
    expect(seasonGuess('Jujutsu Kaisen Season 2'), 2);
    expect(seasonGuess('Mushoku Tensei 2nd Season'), 2);
    expect(seasonGuess('One Piece'), isNull);
  });

  test('hash of a zero filled file is its size', () async {
    final dir = await Directory.systemTemp.createTemp('hash');
    final file = File('${dir.path}/zero.bin')
      ..writeAsBytesSync(List.filled(131072, 0));
    expect(await openSubtitlesHash(file.path), '0000000000020000');
    expect(
      await openSubtitlesHash(
        (File('${dir.path}/s.bin')..writeAsBytesSync([1])).path,
      ),
      isNull,
    );
    await dir.delete(recursive: true);
  });
}
