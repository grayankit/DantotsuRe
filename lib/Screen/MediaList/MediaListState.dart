import 'package:flutter/material.dart';

import '../../Api/Discord/DiscordPresence.dart';
import '../../Core/Services/MediaService.dart';
import '../../Core/Services/Model/Media.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Widgets/Components/ScreenState.dart';

class MediaListState extends ScreenState {
  final MediaService service;
  final bool anime;
  final String? userId;
  final String? userName;

  MediaListState({
    required this.service,
    required this.anime,
    this.userId,
    this.userName,
  });

  static const loadingKey = 'Loading';

  static final _skeletonLists = <String, List<Media>>{
    for (var i = 0; i < 4; i++)
      '$loadingKey $i': [for (var j = 0; j < 12; j++) Media.skeleton()],
  };

  final lists = Live<Map<String, List<Media>>?>(null);
  final failed = false.live;
  TabController? _tabs;

  bool get loading => lists.value == null && !failed.value;

  Map<String, List<Media>> get shown =>
      failed.value ? <String, List<Media>>{} : (lists.value ?? _skeletonLists);

  String get title {
    final owner = userName ?? service.auth?.user.value?.name;
    if (owner == null) {
      return anime ? getString.animeList : getString.mangaList;
    }
    return anime
        ? getString.ownerAnimeList(owner)
        : getString.ownerMangaList(owner);
  }

  DiscordPresence get presence =>
      DiscordPresence.browsing('Browsing a ${anime ? 'anime' : 'manga'} list');

  @override
  void onInit() => load();

  Future<void> load() async {
    final user = service.auth?.user.value;
    final queries = service.getQueries;
    if (queries == null) {
      if (mounted) failed.value = true;
      return;
    }
    try {
      final result = await queries.getMediaLists(
        anime: anime,
        userId: userId == null ? user?.id : int.tryParse(userId!),
      );
      if (!mounted) return;
      lists.value = result;
      failed.value = false;
    } catch (_) {
      if (mounted) failed.value = true;
    }
  }

  TabController controllerFor(int length) {
    final current = _tabs;
    if (current != null && current.length == length) return current;
    final index = current == null ? 0 : current.index.clamp(0, length - 1);
    current?.dispose();
    return _tabs = TabController(
      length: length,
      vsync: vsync,
      initialIndex: index,
    );
  }

  @override
  void onClose() => _tabs?.dispose();
}
