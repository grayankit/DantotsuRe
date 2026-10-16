import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../Core/Preferences/PrefManager.dart';
import '../../../Core/Services/Api/SauceNao.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Widgets/Components/AlertDialogBuilder.dart';
import '../../../Widgets/Components/ScreenState.dart';

class SauceState extends ScreenState {
  final link = TextEditingController();
  final bytes = Live<Uint8List?>(null);
  final url = Live<String?>(null);
  final hits = Live<List<SauceHit>?>(null);
  final busy = false.live;
  final error = Live<String?>(null);

  @override
  void onClose() => link.dispose();

  Future<void> pick() async {
    if (busy.value) return;
    final files = await FilePicker.pickFiles(type: FileType.image);
    if (files.isEmpty) return;
    final file = files.first;
    final data = await file.readAsBytes();
    bytes.value = data;
    url.value = null;
    await _run(() => SauceNao.byBytes(data, name: file.name));
  }

  Future<void> submitLink() async {
    final text = link.text.trim();
    if (text.isEmpty || busy.value) return;
    if (!text.startsWith('http://') && !text.startsWith('https://')) {
      error.value = getString.imageSearchNotLink;
      return;
    }
    bytes.value = null;
    url.value = text;
    await _run(() => SauceNao.byUrl(text));
  }

  Future<void> _run(Future<List<SauceHit>> Function() search) async {
    busy.value = true;
    error.value = null;
    hits.value = null;
    try {
      hits.value = await search();
    } catch (e) {
      error.value = '$e';
    } finally {
      busy.value = false;
    }
  }

  void editKey() {
    final field = TextEditingController(text: PrefName.sauceNaoKey.value);
    AlertDialogBuilder(context)
        .setTitle(getString.sauceKeyTitle)
        .setCustomView(
          TextField(
            controller: field,
            decoration: InputDecoration(
              hintText: getString.sauceKeyHint,
              helperText: getString.sauceKeyDesc,
              prefixIcon: const Icon(Icons.key_rounded),
            ),
          ),
        )
        .setNegativeButton(getString.cancel, null)
        .setPositiveButton(getString.ok, () {
          PrefName.sauceNaoKey.value = field.text.trim();
        })
        .show();
  }
}
