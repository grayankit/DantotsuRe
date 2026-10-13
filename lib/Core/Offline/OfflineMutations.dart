import '../../Utils/Functions/SnackBar.dart';
import '../Services/Api/Progress.dart';
import '../Services/MediaService.dart';
import '../Services/Model/Media.dart';
import '../State/State.dart';
import '../ThemeManager/LanguageSwitcher.dart';
import 'NetStatus.dart';
import 'OfflineMode.dart';
import 'PendingWrites.dart';

class OfflineMutations extends Mutations {
  final MediaService service;
  final Mutations inner;

  OfflineMutations(this.service, this.inner);

  bool get _offline =>
      find<OfflineMode>().isOffline.value || !find<NetStatus>().online.value;

  @override
  Future<void> editList(Media media, {List<String>? customList}) async {
    if (_offline) {
      find<PendingWrites>().record(
        service,
        media,
        PendingKind.edit,
        customList: customList,
      );
      return snackString(getString.offlineSaved);
    }
    await inner.editList(media, customList: customList);
  }

  @override
  Future<void> saveEntry(Media media, {bool? exists}) =>
      inner.saveEntry(media, exists: exists);

  @override
  Future<void> deleteFromList(Media media) async {
    if (_offline) {
      find<PendingWrites>().record(service, media, PendingKind.delete);
      return snackString(getString.offlineSaved);
    }
    await inner.deleteFromList(media);
  }

  @override
  Future<void> setProgress(Media media, int progress) async {
    if (_offline) {
      applyProgress(media, progress);
      find<PendingWrites>().record(
        service,
        media,
        PendingKind.progress,
        progress: progress,
      );
      return snackString(getString.offlineSaved);
    }
    await inner.setProgress(media, progress);
  }
}
