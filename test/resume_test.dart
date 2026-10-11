import 'package:flutter_test/flutter_test.dart';

import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';

import 'package:dartotsu/Core/Media/MediaRecord.dart';
import 'package:dartotsu/Core/Media/ResumeStore.dart';
import 'package:dartotsu/Core/Watch/EpisodeUnits.dart';
import 'package:dartotsu/Core/Watch/LocalProgress.dart';

ResumeEntry entry({double number = 5, int? progress}) => ResumeEntry(
  kind: ResumeKind.watch,
  serviceId: 'anilist',
  media: {'id': '1', 'name': 'One Piece'},
  sourceId: 's',
  unitKey: '$number',
  number: number,
  title: 'Episode',
  thumbnail: null,
  position: 120,
  duration: 1400,
  at: 1,
  progress: progress,
);

void main() {
  test('entry survives a json round trip', () {
    final back = ResumeEntry.fromJson(entry(progress: 4).toJson())!;
    expect(back.mediaId, '1');
    expect(back.slot, 'anilist/watch/1');
    expect(back.progress, 4);
    expect(back.number, 5);
    expect(back.mediaTitle, 'One Piece');
    expect(back.fraction, closeTo(120 / 1400, 1e-9));
  });

  test('broken json is ignored', () {
    expect(ResumeEntry.fromJson(null), isNull);
    expect(ResumeEntry.fromJson({'media': {}}), isNull);
    expect(
      ResumeEntry.fromJson({
        'media': {'id': 1},
        'service': 's',
      }),
      isNull,
    );
  });

  test('an episode at or below the list progress is hidden', () {
    final e = entry();
    expect(ResumeStore.hides(e, null), isFalse);
    expect(ResumeStore.hides(e, 4), isFalse);
    expect(ResumeStore.hides(e, 5), isTrue);
    expect(ResumeStore.hides(e, 9), isTrue);
  });

  WatchUnit unit(int n) => WatchUnit(
    raw: DEpisode(episodeNumber: '$n'),
    number: '$n',
    value: n.toDouble(),
    title: 'Episode $n',
  );

  test('a locally finished episode moves progress past the service', () {
    final units = [for (var i = 1; i <= 5; i++) unit(i)];
    final playback = {
      '3': Playback(position: 1300, duration: 1400),
      '4': Playback(position: 200, duration: 1400),
    };
    expect(effectiveProgress(2, units, playback), 3);
    expect(effectiveProgress(4, units, playback), 4);
    expect(effectiveProgress(0, units, {}), 0);
  });

  test('only part-watched episodes get a progress bar', () {
    expect(partialFraction(null), isNull);
    expect(partialFraction(Playback(position: 0, duration: 100)), isNull);
    expect(partialFraction(Playback(position: 95, duration: 100)), isNull);
    expect(partialFraction(Playback(position: 40, duration: 100)), 0.4);
  });
}
