import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../Api/Discord/DiscordPresence.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'SettingsCategories.dart';
import 'Widgets/DonateSheet.dart';

class SettingsState extends ScreenState {
  DiscordPresence get presence => DiscordPresence.browsing('Tweaking settings');

  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) maybeShowDonateSheet(context);
    });
    if (settingsAppVersion.value.isEmpty) {
      PackageInfo.fromPlatform().then(
        (i) => settingsAppVersion.value = 'v${i.version}+${i.buildNumber}',
      );
    }
  }
}
