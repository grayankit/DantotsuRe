import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../Core/Fonts/AppFonts.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Utils/Functions/NavigateToScreen.dart';
import 'AppSheet.dart';
import 'CustomBottomDialog.dart';
import 'SheetTile.dart';

Future<String?> showFontSheet(
  BuildContext context, {
  required String title,
  required String selected,
}) => showCustomBottomDialog<String>(
  context,
  FractionallySizedBox(
    heightFactor: 0.7,
    child: _FontSheet(title: title, selected: selected),
  ),
);

class _FontSheet extends StatefulWidget {
  final String title;
  final String selected;

  const _FontSheet({required this.title, required this.selected});

  @override
  State<_FontSheet> createState() => _FontSheetState();
}

class _FontSheetState extends State<_FontSheet> {
  final _files = <String>[].liveList;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final files = await savedFontFiles();
    if (mounted) _files.value = files;
  }

  Future<void> _import() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['ttf', 'otf'],
    );
    final path = picked?.path;
    if (path == null) return;
    final saved = await importFontFile(path);
    await _refresh();
    if (mounted) popPage(context, saved);
  }

  Widget _tile(
    BuildContext context,
    String value,
    String label, {
    required bool first,
    required bool last,
  }) {
    final family = fontFamilyOf(value);
    return SheetTile(
      tinted: true,
      radius: BorderRadius.vertical(
        top: Radius.circular(first ? 20 : 6),
        bottom: Radius.circular(last ? 20 : 6),
      ),
      title: Text(label),
      subtitle: Text(
        getString.fontSample,
        style: TextStyle(fontFamily: family),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      selected: value == widget.selected,
      onTap: () => popPage(context, value),
    );
  }

  @override
  Widget build(BuildContext context) => AppSheet(
    title: widget.title,
    heightFactor: 1,
    child: Watch(() {
      fontsTick.value;
      final values = ['', bundledFont, ..._files];
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          for (final (i, value) in values.indexed)
            _tile(
              context,
              value,
              value.isEmpty
                  ? getString.fontAppDefault
                  : fontLabel(value, getString.fontAppDefault),
              first: i == 0,
              last: i == values.length - 1,
            ),
          if (!values.contains(widget.selected) && widget.selected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _tile(
                context,
                widget.selected,
                fontLabel(widget.selected, getString.fontAppDefault),
                first: true,
                last: true,
              ),
            ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: _import,
            icon: const Icon(Icons.add_rounded),
            label: Text(getString.fontImport),
          ),
        ],
      );
    }),
  );
}
