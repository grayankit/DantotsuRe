import 'dart:async';

import 'package:flutter/material.dart';

import '../../Api/Discord/DiscordPresence.dart';
import '../../Core/Services/MediaServiceController.dart';
import '../../Core/Services/Model/Media.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Utils/Functions/NavigateToScreen.dart';
import '../../Widgets/Components/ScreenState.dart';
import '../Detail/DetailScreen.dart';
import '../Social/SocialNavigation.dart';

class NotificationsState extends ScreenState {
  final NotificationScreenView view;

  NotificationsState(this.view);

  final items = <ServiceNotification>[].liveList;
  final loading = true.live;
  final loadingMore = false.live;
  var _page = 1;
  var _hasMore = true;

  MediaService get service =>
      find<MediaServiceController>().currentService.value;

  DiscordPresence get presence =>
      DiscordPresence.browsing('Checking notifications');

  @override
  void onInit() => unawaited(load());

  Future<void> load() async {
    loading.value = true;
    _page = 1;
    _hasMore = true;
    try {
      items.value = await view.notifications();
      final auth = service.auth;
      if (auth != null) unawaited(auth.refreshUser());
    } catch (_) {
    } finally {
      loading.value = false;
    }
  }

  Future<void> more() async {
    if (loadingMore.value || loading.value || !_hasMore) return;
    loadingMore.value = true;
    try {
      final next = await view.notifications(page: _page + 1);
      final known = {for (final n in items) n.id};
      final fresh = next.where((n) => !known.contains(n.id)).toList();
      if (fresh.isEmpty) {
        _hasMore = false;
      } else {
        items.addAll(fresh);
        _page++;
      }
    } catch (_) {
      _hasMore = false;
    } finally {
      loadingMore.value = false;
    }
  }

  bool onScroll(ScrollNotification n) {
    if (n.metrics.axis == Axis.vertical && n.metrics.extentAfter < 500) {
      unawaited(more());
    }
    return false;
  }

  bool canOpen(ServiceNotification n) =>
      n.mediaId != null || n.activityId != null || n.userId != null;

  void open(ServiceNotification n) {
    final current = service;
    if (n.mediaId == null) {
      if (n.activityId != null) {
        return openActivityFeed(context, current, activityId: n.activityId);
      }
      if (n.userId != null) {
        return openProfile(context, current, id: n.userId);
      }
      return;
    }
    navigateToPage(
      context,
      DetailScreen(
        media: Media(
          id: n.mediaId!,
          cover: n.imageUrl,
          shareLink: 'https://anilist.co/anime/${n.mediaId}',
        ),
        view: current.detailView,
        mutations: current.getMutations,
      ),
      hero: true,
    );
  }

  List<(String, List<ServiceNotification>)> grouped() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayLabel = getString.calendarToday;
    final weekLabel = getString.thisWeek;
    final earlierLabel = getString.earlier;
    final buckets = <String, List<ServiceNotification>>{
      todayLabel: [],
      weekLabel: [],
      earlierLabel: [],
    };
    for (final n in items) {
      final d = today
          .difference(
            DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day),
          )
          .inDays;
      if (d <= 0) {
        buckets[todayLabel]!.add(n);
      } else if (d <= 7) {
        buckets[weekLabel]!.add(n);
      } else {
        buckets[earlierLabel]!.add(n);
      }
    }
    return [
      for (final e in buckets.entries)
        if (e.value.isNotEmpty) (e.key, e.value),
    ];
  }

  static String ago(DateTime time) {
    final d = DateTime.now().difference(time);
    if (d.inMinutes < 1) return getString.justNow.toLowerCase();
    if (d.inMinutes < 60) return getString.minutesAgoShort(d.inMinutes);
    if (d.inHours < 24) return getString.hoursAgoShort(d.inHours);
    if (d.inDays < 7) return getString.daysAgoShort(d.inDays);
    return getString.weeksAgoShort((d.inDays / 7).floor());
  }
}
