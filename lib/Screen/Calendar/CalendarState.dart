import 'dart:async';

import '../../Api/Discord/DiscordPresence.dart';
import '../../Core/Services/MediaServiceController.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Widgets/Components/ScreenState.dart';

class CalendarState extends ScreenState {
  final CalendarScreenView view;

  CalendarState(this.view);

  final entries = <CalendarEntry>[].liveList;
  final loading = true.live;
  final failed = false.live;
  final day = 0.live;

  static DateTime dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

  final today = dayOf(DateTime.now());

  StreamSubscription<List<CalendarEntry>>? _sub;

  MediaService get service =>
      find<MediaServiceController>().currentService.value;

  List<DateTime> get days => [
    for (var i = -1; i <= 5; i++) today.add(Duration(days: i)),
  ];

  List<CalendarEntry> get selectedEntries {
    final selected = today.add(Duration(days: day.value));
    return [
      for (final e in entries)
        if (dayOf(e.airingAt) == selected) e,
    ];
  }

  DiscordPresence get presence =>
      DiscordPresence.browsing(getString.calendarTitle);

  @override
  void onInit() => unawaited(load());

  Future<void> load() async {
    await _sub?.cancel();
    loading.value = true;
    failed.value = false;
    final done = Completer<void>();
    _sub = view.schedule().listen(
      (list) {
        entries.value = list;
        loading.value = false;
      },
      onError: (_) {
        failed.value = entries.isEmpty;
        loading.value = false;
        if (!done.isCompleted) done.complete();
      },
      onDone: () {
        loading.value = false;
        if (!done.isCompleted) done.complete();
      },
    );
    await done.future;
  }

  @override
  void onClose() => unawaited(_sub?.cancel());
}
