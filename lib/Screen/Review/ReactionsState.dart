import 'dart:async';

import '../../Core/Services/MediaServiceController.dart';
import '../../Core/Services/Model/Media.dart';
import '../../Core/State/State.dart';
import '../../Widgets/Components/ScreenState.dart';

class ReactionsState extends ScreenState {
  final Media media;
  final DetailScreenView view;

  ReactionsState({required this.media, required this.view});

  final items = <MediaReaction>[].liveList;
  final loading = true.live;

  @override
  void onInit() => unawaited(load());

  Future<void> load() async {
    try {
      items.value = await view.reactions(media);
    } catch (_) {
    } finally {
      loading.value = false;
    }
  }
}
