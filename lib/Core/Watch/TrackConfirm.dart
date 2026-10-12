import 'dart:async';

import 'package:flutter/material.dart';

import '../../Utils/Extensions/ContextExtensions.dart';
import '../../Widgets/Components/AlertDialogBuilder.dart';
import '../State/State.dart';
import '../ThemeManager/LanguageSwitcher.dart';
import 'WatchPrefs.dart';

enum TrackChoice { service, local, none }

Future<TrackChoice> confirmTracking(
  BuildContext? context, {
  required bool anime,
  required String name,
}) async {
  final pref = anime ? trackAnimePref : trackMangaPref;
  final mode = pref.value;
  if (mode == 'always') return TrackChoice.service;
  if (mode == 'never') return TrackChoice.local;
  if (mode == 'off') return TrackChoice.none;
  final host = context ?? appContext;
  if (host == null || !host.mounted) return TrackChoice.service;
  final done = Completer<TrackChoice>();
  final remember = false.live;
  void answer(TrackChoice choice) {
    if (done.isCompleted) return;
    if (remember.value) {
      pref.value = switch (choice) {
        TrackChoice.service => 'always',
        TrackChoice.local => 'never',
        TrackChoice.none => 'off',
      };
    }
    done.complete(choice);
  }

  AlertDialogBuilder(host)
    ..setTitle(getString.trackProgressTitle)
    ..setMessage(
      anime
          ? getString.trackProgressAnime(name)
          : getString.trackProgressManga(name),
    )
    ..setCustomView(
      Watch(
        () => CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            getString.trackProgressRemember,
            style: host.textTheme.bodyMedium,
          ),
          value: remember.value,
          onChanged: (v) => remember.value = v ?? false,
        ),
      ),
    )
    ..setCancelable(false)
    ..setPositiveButton(
      getString.trackProgressYes,
      () => answer(TrackChoice.service),
    )
    ..setNeutralButton(
      getString.trackProgressLocal,
      () => answer(TrackChoice.local),
    )
    ..setNegativeButton(
      getString.trackProgressNo,
      () => answer(TrackChoice.none),
    )
    ..show<void>().ignore();
  return done.future;
}
