import 'package:flutter/material.dart';

import '../../Core/Services/MediaService.dart';
import '../../Core/Services/Model/Media.dart';
import '../../Utils/Functions/NavigateToScreen.dart';
import '../Detail/DetailScreen.dart';
import '../Social/SocialNavigation.dart';

bool canOpenNotification(ServiceNotification n) =>
    n.mediaId != null || n.activityId != null || n.userId != null;

void openNotification(
  BuildContext context,
  MediaService service,
  ServiceNotification n,
) {
  if (n.mediaId == null) {
    if (n.activityId != null) {
      return openActivityFeed(context, service, activityId: n.activityId);
    }
    if (n.userId != null) {
      return openProfile(context, service, id: n.userId);
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
      view: service.detailView,
      mutations: service.getMutations,
    ),
    hero: true,
  );
}
