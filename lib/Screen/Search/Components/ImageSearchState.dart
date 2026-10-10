import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../Core/Services/Api/TraceMoe.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Widgets/Components/ScreenState.dart';

class ImageSearchState extends ScreenState {
  final link = TextEditingController();
  final bytes = Live<Uint8List?>(null);
  final url = Live<String?>(null);
  final hits = Live<List<TraceHit>?>(null);
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
    await _run(() => TraceMoe.byBytes(data, name: file.name));
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
    await _run(() => TraceMoe.byUrl(text));
  }

  Future<void> _run(Future<List<TraceHit>> Function() search) async {
    busy.value = true;
    error.value = null;
    hits.value = null;
    try {
      final found = await search();
      hits.value = found;
    } catch (e) {
      error.value = '$e';
    } finally {
      busy.value = false;
    }
  }
}
