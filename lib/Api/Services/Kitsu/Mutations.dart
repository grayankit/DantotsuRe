import '../../../Core/Preferences/Incognito.dart';
import '../../../Core/Services/Api/Mutations.dart';
import '../../../Core/Services/Model/Media.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Functions/RefreshController.dart';
import '../../../Utils/Functions/SnackBar.dart';
import 'Client.dart';
import 'Data/Mapper.dart';

class KitsuMutations extends Mutations {
  final KitsuClient client;
  final int? Function() userId;
  final void Function() onChanged;

  KitsuMutations(this.client, {required this.userId, required this.onChanged});

  @override
  Future<void> editList(Media media, {List<String>? customList}) async {
    if (incognitoBlocksEdits) {
      snackString(getString.incognitoEditsBlocked);
      return;
    }
    final score = ((media.userScore ?? 0) / 5).round().clamp(0, 20);
    await _save(media, {
      if (kitsuStatusOut(media.userStatus) != null)
        'status': kitsuStatusOut(media.userStatus),
      'ratingTwenty': score < 2 ? null : score,
      if (media.userProgress != null) 'progress': media.userProgress,
      'reconsuming': media.userStatus == 'REPEATING',
      'reconsumeCount': media.userRepeat,
      'notes': media.notes ?? '',
      'startedAt': kitsuDateOut(media.userStartedAt),
      'finishedAt': kitsuDateOut(media.userCompletedAt),
    });
  }

  @override
  Future<void> deleteFromList(Media media) async {
    final ref = parseKitsuMediaId(media.id);
    if (ref == null) return;
    try {
      final entry = await _entryId(media, ref);
      if (entry != null) await client.delete('/library-entries/$entry');
      _done();
    } on KitsuException catch (e) {
      snackString(getString.serviceError(getString.kitsu, e.message));
    }
  }

  @override
  Future<void> setProgress(Media media, int progress) async {
    if (incognitoBlocksEdits) return;
    final total = media.totalUnits;
    final done = total != null && total > 0 && progress >= total;
    await _save(media, {
      'progress': progress,
      'status': done
          ? 'completed'
          : kitsuStatusOut(media.userStatus) == null ||
                media.userStatus == 'PLANNING'
          ? 'current'
          : kitsuStatusOut(media.userStatus),
    });
  }

  Future<int?> _entryId(Media media, (bool, int) ref) async {
    if (media.userListId != null) return media.userListId;
    final user = userId();
    if (user == null) return null;
    final kind = ref.$1 ? 'anime' : 'manga';
    final res = await client.get(
      '/library-entries',
      query: {
        'filter[userId]': '$user',
        'filter[${kind}Id]': '${ref.$2}',
        'fields[libraryEntries]': 'status',
        'page[limit]': '1',
      },
    );
    final data = (res['data'] as List?) ?? const [];
    return data.isEmpty ? null : int.tryParse('${(data.first as Map)['id']}');
  }

  Future<void> _save(Media media, Map<String, dynamic> attributes) async {
    final ref = parseKitsuMediaId(media.id);
    final user = userId();
    if (ref == null || user == null) return;
    final kind = ref.$1 ? 'anime' : 'manga';
    try {
      final entry = await _entryId(media, ref);
      if (entry == null) {
        await client.post('/library-entries', {
          'data': {
            'type': 'libraryEntries',
            'attributes': {'status': 'current', ...attributes},
            'relationships': {
              'user': {
                'data': {'type': 'users', 'id': '$user'},
              },
              'media': {
                'data': {'type': kind, 'id': '${ref.$2}'},
              },
            },
          },
        });
      } else {
        await client.patch('/library-entries/$entry', {
          'data': {
            'type': 'libraryEntries',
            'id': '$entry',
            'attributes': attributes,
          },
        });
      }
      _done();
    } on KitsuException catch (e) {
      snackString(getString.serviceError(getString.kitsu, e.message));
    }
  }

  void _done() {
    onChanged();
    tryFind<RefreshController>()?.all();
  }
}
