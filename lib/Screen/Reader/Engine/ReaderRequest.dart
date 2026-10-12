import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';

import '../../../Core/Services/MediaService.dart';
import '../../../Core/Services/Model/Media.dart';
import '../../Detail/Watch/Data/EpisodeUnits.dart';

class ReaderRequest {
  final MediaService service;
  final Media media;
  final Source source;
  List<WatchUnit> units;
  final int index;
  final List<PageUrl>? pages;
  final Future<List<WatchUnit>?> Function()? loadUnits;

  ReaderRequest({
    required this.service,
    required this.media,
    required this.source,
    required this.units,
    required this.index,
    this.pages,
    this.loadUnits,
  });

  ReaderRequest withPages(List<PageUrl> loaded) => ReaderRequest(
    service: service,
    media: media,
    source: source,
    units: units,
    index: index,
    pages: loaded,
    loadUnits: loadUnits,
  );

  bool get novel => media.format?.toLowerCase() == 'novel';
}
