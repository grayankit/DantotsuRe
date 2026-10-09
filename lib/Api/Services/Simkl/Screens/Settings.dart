import 'package:flutter/material.dart';
import '../../../../Core/Services/MediaService.dart';
import '../../../../Model/Setting.dart';
import '../../../../Utils/Function.dart';
import '../../../../Utils/Functions/SnackBar.dart';
import '../Auth.dart';
import '../Data/User.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';

class SimklSettingsView extends SettingsScreenView {
  @override
  List<Setting> build(BuildContext context) {
    final user = simklAuth.user.value;
    return [
      if (user is SimklUser)
        Setting.normal(
          name: getString.simklProfile,
          description: user.name,
          icon: Icons.person_outline_rounded,
          onClick: () => openLinkInBrowser(user.profileUrl),
        ),
      Setting.normal(
        name: getString.refreshFromSimkl,
        description: getString.repullProfileLibrary,
        icon: Icons.refresh_rounded,
        onClick: () async {
          simklAuth.queries.clearLibrary();
          await simklAuth.refreshUser();
          snackString(getString.refreshed);
        },
      ),
    ];
  }
}
