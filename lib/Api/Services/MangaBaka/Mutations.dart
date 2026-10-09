import '../../../Core/Preferences/Incognito.dart';
import '../../../Core/Services/Api/Mutations.dart';
import '../../../Core/Services/Model/Media.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Functions/RefreshController.dart';
import '../../../Utils/Functions/SnackBar.dart';
import 'Client.dart';
import 'Data/Mapper.dart';
import 'Queries.dart';

class MangaBakaMutations extends Mutations {
  final MangaBakaClient client;
  final MangaBakaQueries queries;

  MangaBakaMutations(this.client, this.queries);

  @override
  Future<void> editList(Media media, {List<String>? customList}) async {
    if (incognitoBlocksEdits) {
      snackString(getString.incognitoEditsBlocked);
      return;
    }
    final score = media.userScore ?? 0;
    await _save(media, {
      'state': mangaBakaStateOut(media.userStatus),
      'rating': score <= 0 ? null : (score / queries.ratingScale).round(),
      if (media.userProgress != null) 'progress_chapter': media.userProgress,
      'number_of_rereads': media.userRepeat,
      'note': media.notes ?? '',
      'start_date': mangaBakaDateOut(media.userStartedAt),
      'finish_date': mangaBakaDateOut(media.userCompletedAt),
    });
  }

  @override
  Future<void> deleteFromList(Media media) async {
    try {
      await client.delete('/my/library/${media.id}');
      _done();
    } on MangaBakaException catch (e) {
      snackString(getString.serviceError(getString.mangaBaka, e.message));
    }
  }

  @override
  Future<void> setProgress(Media media, int progress) async {
    if (incognitoBlocksEdits) return;
    final total = media.totalUnits;
    final done = total != null && total > 0 && progress >= total;
    final status = media.userStatus;
    await _save(media, {
      'progress_chapter': progress,
      'state': done
          ? 'completed'
          : status == null || status == 'PLANNING'
          ? 'reading'
          : mangaBakaStateOut(status),
    });
  }

  Future<void> _save(Media media, Map<String, dynamic> body) async {
    final path = '/my/library/${media.id}';
    try {
      if (media.userListId != null) {
        await client.write('PUT', path, body);
      } else {
        try {
          await client.write('POST', path, {'state': 'reading', ...body});
        } on MangaBakaException catch (e) {
          if (e.status != 409) rethrow;
          await client.write('PUT', path, body);
        }
      }
      _done();
    } on MangaBakaException catch (e) {
      snackString(getString.serviceError(getString.mangaBaka, e.message));
    }
  }

  void _done() {
    queries.invalidateLibrary();
    tryFind<RefreshController>()?.all();
  }
}
