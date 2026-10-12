import 'package:dartotsu/Screen/Player/Engine/PlayerEngine.dart';
import 'package:dartotsu/Screen/Player/Engine/TrackPick.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tracks = [
    PlayerTrack('1', 'Signs & Songs', 'eng'),
    PlayerTrack('2', 'Full English', 'eng'),
    PlayerTrack('3', null, 'ja'),
    PlayerTrack('4', 'Español (Latino)', null),
  ];

  test('splits a priority list', () {
    expect(languageList('English, Spanish;  '), ['English', 'Spanish']);
    expect(languageList(''), isEmpty);
  });

  test('matches by language code or title and skips signs', () {
    expect(pickTrack(tracks, ['English'], avoidSigns: true)?.id, '2');
    expect(pickTrack(tracks, ['English'])?.id, '1');
    expect(pickTrack(tracks, ['Japanese'])?.id, '3');
    expect(pickTrack(tracks, ['Spanish'])?.id, '4');
  });

  test('honours the order and returns null when nothing matches', () {
    expect(pickTrack(tracks, ['Korean', 'Japanese'])?.id, '3');
    expect(pickTrack(tracks, ['Korean']), isNull);
  });
}
