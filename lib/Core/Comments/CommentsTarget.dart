import '../../Api/Services/Anilist/AnilistService.dart';
import '../../Logger.dart';
import '../Preferences/PrefManager.dart';
import '../Services/MediaServiceController.dart';
import '../Services/Model/Media.dart';
import '../State/State.dart';
import '../Sync/SyncIdIndex.dart';
import '../Sync/SyncModels.dart';

class CommentsTarget {
  CommentsTarget._();

  static final _pending = <String, Future<int?>>{};

  static String _key(MediaService service, Media media) =>
      'commentsTarget/${service.id}/${media.id}';

  static int? cached(MediaService service, Media media) {
    if (service.id == anilistServiceId) return int.tryParse(media.id);
    return PrefManager.getCustomVal<int>(
      _key(service, media),
      location: PrefLocation.CACHE,
    );
  }

  static Future<int?> resolve(MediaService service, Media media) {
    final known = cached(service, media);
    if (known != null) return Future.value(known);
    return _pending[_key(service, media)] ??= _lookup(service, media)
        .whenComplete(() {
          _pending.remove(_key(service, media));
        });
  }

  static Future<int?> _lookup(MediaService service, Media media) async {
    final adapter = service.syncAdapter;
    if (adapter == null) return null;
    var ids = adapter.idsOf(media);
    if (ids[SyncKey.anilist] == null) {
      try {
        ids = {...ids, ...await adapter.foreignIds(media)};
      } catch (e) {
        logger('Comments foreignIds failed: $e', logLevel: LogLevel.error);
      }
    }
    final anime = media.isAnime || media.id.startsWith('anime/');
    if (ids[SyncKey.anilist] == null && anime) {
      try {
        ids = (await SyncIdIndex.load()).expand(ids, prefer: adapter.key);
      } catch (e) {
        logger('Comments id index failed: $e', logLevel: LogLevel.error);
      }
    }
    var id = ids[SyncKey.anilist];
    final mal = ids[SyncKey.mal];
    if (id == null && mal != null) {
      final anilist = find<MediaServiceController>().services.firstWhere(
        (s) => s.id == anilistServiceId,
      );
      try {
        final (found, _) =
            await anilist.syncAdapter?.resolve([mal], anime: anime) ??
            (const <int, int>{}, 0);
        id = found[mal];
      } catch (e) {
        logger('Comments AniList lookup failed: $e', logLevel: LogLevel.error);
      }
    }
    logger('Comments target ${service.id}/${media.id} -> $ids -> $id');
    if (id != null) {
      PrefManager.setCustomVal<int>(
        _key(service, media),
        id,
        location: PrefLocation.CACHE,
      );
    }
    return id;
  }
}
