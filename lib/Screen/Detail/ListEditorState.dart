import 'dart:async';

import 'package:flutter/material.dart';

import '../../Core/Preferences/PrefManager.dart';
import '../../Core/Services/MediaService.dart';
import '../../Core/Services/Model/Media.dart';
import '../../Core/Services/Screens/DetailCache.dart';
import '../../Core/State/State.dart';
import '../../Core/Sync/SyncController.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Utils/Functions/NavigateToScreen.dart';
import '../../Utils/Functions/SnackBar.dart';
import '../../Widgets/Components/ScreenState.dart';

class ListEditorSession {
  final Media media;
  final ListEditorScreenView view;
  final Mutations mutations;
  final Future<void> Function() onSaved;

  ListEditorSession({
    required this.media,
    required this.view,
    required this.mutations,
    required this.onSaved,
  }) : draft = ListEditorDraft(media, customLists: view.customLists(media));

  final ListEditorDraft draft;

  bool get canRemove {
    final local = mutations;
    return media.userListId != null ||
        (local is LocalMutations && local.has(media));
  }

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
    String done,
  ) async {
    if (context.mounted) popPage(context);
    try {
      await action();
      await onSaved();
      snackString(done);
    } catch (e) {
      snackString('$e');
    }
  }

  Future<void> save(BuildContext context) => _run(context, () async {
    draft.applyTo(media);
    await mutations.editList(
      media,
      customList: view.advanced ? draft.selectedCustomLists : null,
    );
    final sync = find<SyncController>();
    if (PrefName.syncOnEdit.value &&
        sync.canPush(view.service, media.isAnime)) {
      unawaited(sync.pushEdit(view.service, media));
    }
  }, getString.savedToList);

  Future<void> remove(BuildContext context) => _run(
    context,
    () => mutations.deleteFromList(media),
    getString.removedFromYourList,
  );
}

class QuickListEditorState extends ScreenState {
  final MediaService service;
  final Media media;
  final Mutations mutations;

  QuickListEditorState({
    required this.service,
    required this.media,
    required this.mutations,
  });

  late final String key = '${service.id}/${media.id}';
  late final ListEditorScreenView view = service.detailView.listEditor;
  final full = Live<Media?>(null);

  @override
  void onInit() {
    full.value = DetailCache.get(key);
    if (full.value == null) unawaited(load());
  }

  Future<void> load() async {
    Media? loaded;
    try {
      loaded = await service.getQueries?.mediaDetails(media);
      if (loaded != null) DetailCache.put(key, loaded);
    } catch (_) {}
    if (mounted) full.value = loaded ?? media;
  }

  Future<void> invalidate() async => DetailCache.remove(key);
}
