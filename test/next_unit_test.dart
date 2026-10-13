import 'package:dartotsu/Screen/Detail/Watch/Data/EpisodeUnits.dart';
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter_test/flutter_test.dart';

WatchUnit unit(double value, [String? scanlator]) => WatchUnit(
  raw: DEpisode(episodeNumber: '$value'),
  number: '${value.toInt()}',
  value: value,
  title: '',
  scanlator: scanlator,
);

void main() {
  group('nextUnitIndex', () {
    test('skips the same chapter uploaded by other scanlators', () {
      final units = [
        unit(2, 'a'),
        unit(3, 'a'),
        unit(3, 'b'),
        unit(3, 'c'),
        unit(4, 'a'),
      ];
      expect(nextUnitIndex(units, 1), 4);
      expect(nextUnitIndex(units, 0), 1);
    });

    test('keeps parts of one upload in order', () {
      final units = [unit(3), unit(3), unit(3), unit(4)];
      expect(nextUnitIndex(units, 0), 1);
      expect(nextUnitIndex(units, 2), 3);
    });

    test('ends after the last unit', () {
      final units = [unit(1, 'a'), unit(1, 'b')];
      expect(nextUnitIndex(units, 0), 2);
      expect(nextUnitIndex(units, 1), 2);
    });
  });

  group('withoutDuplicateChapters', () {
    test('keeps one upload of each chapter', () {
      final units = [
        unit(2, 'a'),
        unit(3, 'a'),
        unit(3, 'b'),
        unit(3, 'c'),
        unit(4, 'b'),
      ];
      final kept = withoutDuplicateChapters(units);
      expect(kept.map((u) => '${u.value}${u.scanlator}'), [
        '2.0a',
        '3.0a',
        '4.0b',
      ]);
    });

    test('keeps every part of a single upload', () {
      final units = [unit(3), unit(3), unit(3), unit(4)];
      expect(withoutDuplicateChapters(units).length, 4);
    });
  });

  group('unit keys', () {
    List<WatchUnit> build(List<(String, String?, String)> rows) => buildUnits(
      [
        for (final (number, scanlator, name) in rows)
          DEpisode(episodeNumber: number, scanlator: scanlator, name: name),
      ],
      const {},
      fallbackThumb: '',
      anime: false,
    );

    test('chapters map by their number', () {
      final units = build([
        ('1', 'a', 'One'),
        ('1.5', 'a', 'Half'),
        ('2', 'a', 'Two'),
      ]);
      expect(units.map((u) => u.key), ['1', '1.5', '2']);
    });

    test('other scanlators of a chapter share its key', () {
      final units = build([('3', 'a', 'x'), ('3', 'b', 'y'), ('4', 'a', 'z')]);
      expect(units.map((u) => u.key), ['3', '3', '4']);
    });

    test('parts of one upload get their own keys', () {
      final units = build([('3', null, 'Part 1'), ('3', null, 'Part 2')]);
      expect(units[0].key, isNot(units[1].key));
      expect(units[0].key.startsWith('3~'), isTrue);
    });
  });
}
