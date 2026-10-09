import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../Core/Services/MediaService.dart';
import '../../Core/Services/Model/Media.dart';
import '../../Utils/Functions/SnackBar.dart';
import '../../Widgets/Components/CustomBottomDialog.dart';
import '../Widgets/ScreenWidgetView.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'ListEditorState.dart';

CustomBottomDialog _editorDialog(
  BuildContext context, {
  required Media media,
  required ListEditorScreenView view,
  required Mutations mutations,
  required Future<void> Function() onSaved,
}) {
  final session = ListEditorSession(
    media: media,
    view: view,
    mutations: mutations,
    onSaved: onSaved,
  );
  return CustomBottomDialog(
    title: media.mainName,
    viewList: [
      for (final w in view.build(media, session.draft)) ScreenWidgetView(w),
      const SizedBox(height: 12),
    ],
    positiveText: getString.save,
    positiveCallback: () => session.save(context),
    negativeText: session.canRemove ? getString.remove : null,
    negativeCallback: () => session.remove(context),
  );
}

void showListEditor(
  BuildContext context, {
  required Media media,
  required ListEditorScreenView view,
  required Mutations mutations,
  required Future<void> Function() onSaved,
}) {
  showCustomBottomDialog(
    context,
    _editorDialog(
      context,
      media: media,
      view: view,
      mutations: mutations,
      onSaved: onSaved,
    ),
  );
}

void showQuickListEditor(
  BuildContext context,
  MediaService service,
  Media media,
) {
  final mutations = service.getMutations;
  if (mutations == null) {
    snackString(getString.noListToEdit(service.name));
    return;
  }
  unawaited(HapticFeedback.mediumImpact());
  showCustomBottomDialog(
    context,
    _QuickListEditor(service: service, media: media, mutations: mutations),
  );
}

class _QuickListEditor extends StatefulWidget {
  final MediaService service;
  final Media media;
  final Mutations mutations;

  const _QuickListEditor({
    required this.service,
    required this.media,
    required this.mutations,
  });

  @override
  State<_QuickListEditor> createState() => _QuickListEditorState();
}

class _QuickListEditorState extends State<_QuickListEditor>
    with ScreenStateHost<_QuickListEditor, QuickListEditorState> {
  @override
  QuickListEditorState buildState() => QuickListEditorState(
    service: widget.service,
    media: widget.media,
    mutations: widget.mutations,
  );

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  Widget _build(BuildContext context) {
    final full = state.full.value;
    if (full != null) {
      return _editorDialog(
        context,
        media: full,
        view: state.view,
        mutations: widget.mutations,
        onSaved: state.invalidate,
      );
    }
    final draft = ListEditorDraft(
      widget.media,
      customLists: state.view.customLists(widget.media),
    );
    return CustomBottomDialog(
      title: widget.media.mainName,
      viewList: [
        Skeletonizer(
          child: Column(
            children: [
              for (final w in state.view.build(widget.media, draft))
                ScreenWidgetView(w),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
