import 'package:flutter/material.dart';

import '../../../../Core/Services/MediaService.dart';
import '../../../../Screen/Social/SocialNavigation.dart';
import '../../../../Core/Services/Model/Media.dart';
import '../../../../Core/Services/Model/User.dart';
import '../../../../Core/State/State.dart';
import '../../../../Core/ThemeManager/CardStyleController.dart';
import '../../../../Model/CardStyle.dart';
import '../../../../Utils/Extensions/StringExtensions.dart';
import '../../../../Widgets/Shelf/CardShelf.dart';
import '../../../../Widgets/Shelf/CardShelfState.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';

class FollowersShelf extends StatelessWidget {
  final Media media;
  final List<User> users;
  final String? me;
  final MediaService? service;

  const FollowersShelf({
    super.key,
    required this.media,
    required this.users,
    this.me,
    this.service,
  });

  String _status(User user) => user.status == 'CURRENT'
      ? (media.isAnime ? 'WATCHING' : 'READING')
      : (user.status ?? '').titleCase;

  ShelfCardItem _item(BuildContext context, User user) {
    final isMe = user.name == me;
    final score = user.score ?? 0;
    return ShelfCardItem(
      id: '${user.id}',
      imageUrl: user.pfp,
      title: isMe ? 'YOU' : user.name,
      subtitle:
          '${_status(user)} · ${user.progress ?? 0} | ${media.totalUnits ?? "~"}',
      score: score == 0 ? null : score / 10,
      focusable: true,
      onTap: service == null
          ? null
          : () => openProfile(
              context,
              service!,
              id: '${user.id}',
              user: UserBrief(
                id: '${user.id}',
                name: user.name,
                avatar: user.pfp,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordered = [
      ...users.where((u) => u.name == me),
      ...users.where((u) => u.name != me),
    ];
    final style = (tryFind<CardStyleController>()?.current ?? CardStyle.cozy)
        .copyWith(preset: 'people', aspect: 1);
    return CardShelf(
      title: getString.following,
      dataKey: ordered,
      styleOverride: style,
      items: [for (final user in ordered) _item(context, user)],
    );
  }
}
