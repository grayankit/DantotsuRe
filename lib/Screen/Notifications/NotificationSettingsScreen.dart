import 'package:flutter/material.dart';

import '../Detail/Comments/Data/CommentSettings.dart';
import '../../Core/Services/MediaServiceController.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Model/Setting.dart';
import '../../Utils/Extensions/Responsive.dart';
import '../../Widgets/Components/AppBars.dart';
import '../../Widgets/Components/BaseScreen.dart';
import '../../Widgets/Components/ScrollConfig.dart';
import '../Settings/Widgets/SettingsGroup.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends BaseScreen<NotificationSettingsScreen> {
  List<Setting> _all(BuildContext context) => [
    for (final service in find<MediaServiceController>().services)
      if (service.notificationView case final view?)
        if (view.settings(context) case final rows when rows.isNotEmpty) ...[
          Setting.header(service.name),
          ...rows,
        ],
    Setting.header(getString.notificationsCommentsHeader),
    ...commentNotificationSettings(),
  ];

  @override
  Widget buildContent(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    appBar: AppScreenBar(title: getString.notificationsSettings),
    body: ScrollConfig(
      context,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          Dimens.pagePad,
          Dimens.gapSm,
          Dimens.pagePad,
          Dimens.gapXl,
        ),
        children: [Watch(() => SettingsGroup(settings: _all(context)))],
      ),
    ),
  );
}
