import 'package:flutter/material.dart';
import '../../../../Core/Services/MediaService.dart';
import '../../../../Model/Setting.dart';
import '../../../../Utils/Function.dart';
import '../../../../Utils/Functions/SnackBar.dart';
import '../Auth.dart';
import '../Data/User.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';

class MalSettingsView extends SettingsScreenView {
  @override
  List<Setting> build(BuildContext context) {
    final user = malAuth.user.value;
    return [
      if (user is MalUser)
        Setting.normal(
          name: getString.malProfile,
          description: user.name,
          icon: Icons.person_outline_rounded,
          onClick: () => openLinkInBrowser(user.profileUrl),
        ),
      Setting.normal(
        name: getString.refreshFromMal,
        description: getString.repullProfileCounts,
        icon: Icons.refresh_rounded,
        onClick: () async {
          await malAuth.refreshUser();
          snackString(getString.refreshed);
        },
      ),
    ];
  }
}
