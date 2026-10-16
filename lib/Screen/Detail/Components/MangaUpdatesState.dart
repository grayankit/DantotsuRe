import 'dart:async';

import '../../../Core/Services/Api/MangaUpdates.dart';
import '../../../Core/Services/MediaService.dart';
import '../../../Core/Services/Model/Media.dart';
import '../../../Core/State/State.dart';
import '../../../Logger.dart';
import '../../../Utils/Function.dart';
import '../../../Widgets/Components/ScreenState.dart';
import '../Watch/Data/Media/MediaRecord.dart';

class MangaUpdatesState extends ScreenState {
  final MediaService service;
  final Media media;

  MangaUpdatesState(this.service, this.media);

  final info = Live<MuInfo?>(null);
  final loading = true.live;

  @override
  void onInit() => unawaited(_load());

  Future<void> _load() async {
    final record = MediaRecords.of(service, media);
    try {
      info.value = await MangaUpdates.lookup(
        [media.nameRomaji, media.name, ...media.synonyms.take(2)],
        year: media.startDate?.year,
        knownId: record.mangaUpdatesId,
        onMatched: (id) {
          record.mangaUpdatesId = id;
          MediaRecords.save(service, media);
        },
      );
    } catch (e, st) {
      logger(
        'MangaUpdates failed: $e\n$st',
        logLevel: LogLevel.warning,
        tag: 'MANGAUPDATES',
      );
    } finally {
      loading.value = false;
    }
  }

  void open() {
    final url = info.value?.series.url;
    if (url != null && url.isNotEmpty) unawaited(openLinkInBrowser(url));
  }

  void openGroup(MuGroup group) {
    final url = group.url;
    if (url != null && url.isNotEmpty) unawaited(openLinkInBrowser(url));
  }
}
