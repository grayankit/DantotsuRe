import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/material.dart';

import '../../Core/Preferences/PrefManager.dart';
import '../../Core/State/State.dart';
import '../../Utils/Functions/SnackBar.dart';
import '../../Utils/Nav/DpadNav.dart';
import '../../Widgets/Components/ScreenState.dart';

class ExtensionListItem {
  final bool isHeader;
  final String? language;
  final Source? source;

  const ExtensionListItem._({
    required this.isHeader,
    this.language,
    this.source,
  });

  const ExtensionListItem.header(String language)
    : this._(isHeader: true, language: language);

  const ExtensionListItem.source(Source source)
    : this._(isHeader: false, source: source);
}

class ExtensionListState extends ScreenState {
  final ItemType itemType;
  final bool isInstalled;
  final VoidCallback? onFirstRowUp;
  final GlobalKey<DpadRegionState>? firstRowKey;

  ExtensionListState({
    required this.itemType,
    required this.isInstalled,
    this.onFirstRowUp,
    this.firstRowKey,
  });

  String searchQuery = '';

  final ScrollController controller = ScrollController();
  final ExtensionManager manager = find();
  final secondRowKey = GlobalKey<DpadRegionState>();
  final bool showIcons = PrefName.loadExtensionIcon.value;

  Extension get extension => manager[itemType];

  ExtensionState get bridgeState => extension.state(itemType);

  Set<String> get selectedLanguages => bridgeState.selectedLanguages;

  String get searchTerm => searchQuery.trim().toLowerCase();

  Pref<List<String>> get orderPref =>
      PrefName.extensionOrder(extension.name, itemType.name);

  @override
  void onClose() => controller.dispose();

  void reorder(List<Source> installed, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = installed.removeAt(oldIndex);
    installed.insert(newIndex, item);
    bridgeState.installed.value = List<Source>.from(installed);
    saveOrder(installed);
  }

  Future<void> refreshData() async {
    if (isInstalled) {
      await extension.initializeInstalled(itemType);

      switch (itemType) {
        case ItemType.anime:
          await extension.fetchInstalledAnimeExtensions();
          break;
        case ItemType.manga:
          await extension.fetchInstalledMangaExtensions();
          break;
        case ItemType.novel:
          await extension.fetchInstalledNovelExtensions();
          break;
      }
    } else {
      await extension.initializeAvailable(itemType);

      switch (itemType) {
        case ItemType.anime:
          await extension.fetchAnimeExtensions();
          break;
        case ItemType.manga:
          await extension.fetchMangaExtensions();
          break;
        case ItemType.novel:
          await extension.fetchNovelExtensions();
          break;
      }
    }
  }

  List<Source> filteredInstalled() {
    final installed = applySavedOrder(dedupeById(bridgeState.installed.value));

    return installed.where((source) {
      final matchesSearch =
          source.name?.toLowerCase().contains(searchTerm) ?? false;

      final matchesLanguage =
          selectedLanguages.isEmpty || selectedLanguages.contains(source.lang);

      return matchesSearch && matchesLanguage;
    }).toList();
  }

  List<ExtensionListItem> filteredAvailable() {
    final grouped = <String, List<Source>>{};

    for (final source in bridgeState.available.value) {
      final lang = source.lang?.toLowerCase() ?? 'Unknown';

      if (selectedLanguages.isNotEmpty && !selectedLanguages.contains(lang)) {
        continue;
      }

      if (searchTerm.isNotEmpty &&
          !(source.name?.toLowerCase().contains(searchTerm) ?? false)) {
        continue;
      }

      grouped.putIfAbsent(lang, () => []).add(source);
    }

    final entries = grouped.entries.toList()
      ..sort((a, b) {
        const priority = {'all': 0, 'en': 1};

        final pa = priority[a.key] ?? 999;
        final pb = priority[b.key] ?? 999;

        if (pa != pb) {
          return pa.compareTo(pb);
        }

        return a.key.compareTo(b.key);
      });

    return [
      for (final entry in entries) ...[
        ExtensionListItem.header(entry.key),
        ...entry.value.map(ExtensionListItem.source),
      ],
    ];
  }

  List<Source> dedupeById(List<Source> list) {
    final seen = <String?>{};
    return list.where((s) => seen.add(s.id)).toList();
  }

  void saveOrder(List<Source> list) {
    orderPref.value = list.map((e) => e.id).whereType<String>().toList();
  }

  List<Source> applySavedOrder(List<Source> list) {
    final saved = orderPref.value;
    if (saved.isEmpty) return list;

    final order = <String, int>{
      for (var i = 0; i < saved.length; i++) saved[i]: i,
    };

    list.sort((a, b) {
      final ai = order[a.id] ?? 1 << 30;
      final bi = order[b.id] ?? 1 << 30;
      return ai.compareTo(bi);
    });

    return list;
  }

  void runProgressOp(Stream<double> Function() op, String failureLabel) {
    op().drain<void>().catchError((e) {
      snackString('$failureLabel: $e');
    });
  }
}
