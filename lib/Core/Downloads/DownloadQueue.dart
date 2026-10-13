import 'package:dartotsu_extension_bridge/Models/Video.dart' as v;
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';

import '../Services/MediaService.dart';
import '../Services/Model/Media.dart';
import 'DownloadEngine.dart';
import 'DownloadTask.dart';

class DownloadUnit {
  final String key;
  final double number;
  final String title;
  final DEpisode raw;

  const DownloadUnit({
    required this.key,
    required this.number,
    required this.title,
    required this.raw,
  });
}

extension DownloadQueue on DownloadEngine {
  List<DownloadUnit> notQueued(
    MediaService service,
    Media media,
    Iterable<DownloadUnit> units,
  ) => [
    for (final u in units)
      if (taskFor(service.id, media.id, u.key) == null) u,
  ];

  void queueVideos({
    required MediaService service,
    required Media media,
    required Source source,
    required List<DownloadUnit> units,
    required StreamProfile profile,
    required v.Video video,
    required int? height,
    required v.Track? subtitle,
    bool folder = false,
  }) {
    final slim = this.slim(media);
    final now = DateTime.now().millisecondsSinceEpoch;
    enqueue([
      for (final (i, unit) in units.indexed)
        DownloadTask(
          id: DownloadTask.idOf(service.id, media.id, unit.key),
          kind: DownloadKind.video,
          serviceId: service.id,
          mediaId: media.id,
          mediaTitle: media.mainName,
          cover: media.cover,
          sourceId: source.id,
          unitKey: unit.key,
          number: unit.number,
          title: unit.title,
          media: slim,
          episode: Map<String, Object?>.from(unit.raw.toJson()),
          profile: profile,
          createdAt: now + i,
          video: i == 0 ? video.toJson() : null,
          height: height,
          folder: folder,
          subtitle: i == 0 ? subtitle?.toJson() : null,
        ),
    ]);
  }

  void queueChapters({
    required MediaService service,
    required Media media,
    required Source source,
    required List<DownloadUnit> units,
  }) {
    final slim = this.slim(media);
    final now = DateTime.now().millisecondsSinceEpoch;
    enqueue([
      for (final (i, unit) in units.indexed)
        DownloadTask(
          id: DownloadTask.idOf(service.id, media.id, unit.key),
          kind: DownloadKind.chapter,
          serviceId: service.id,
          mediaId: media.id,
          mediaTitle: media.mainName,
          cover: media.cover,
          sourceId: source.id,
          unitKey: unit.key,
          number: unit.number,
          title: unit.title,
          media: slim,
          episode: Map<String, Object?>.from(unit.raw.toJson()),
          profile: null,
          createdAt: now + i,
        ),
    ]);
  }
}
