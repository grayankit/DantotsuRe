import 'package:flutter/material.dart';

import '../../Model/Setting.dart';
import '../../Widgets/Components/BaseScreen.dart';
import 'SettingsListView.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'SubSettingsState.dart';

class SubSettingsScreen extends StatefulWidget {
  final String title;
  final List<Setting> Function(BuildContext) settings;

  const SubSettingsScreen({
    super.key,
    required this.title,
    required this.settings,
  });

  @override
  State<SubSettingsScreen> createState() => _SubSettingsScreenState();
}

class _SubSettingsScreenState extends BaseScreen<SubSettingsScreen>
    with ScreenStateHost<SubSettingsScreen, SubSettingsState> {
  @override
  SubSettingsState buildState() =>
      SubSettingsState(widget.title, widget.settings);

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SettingsListView(title: state.title, searchable: state.build),
    );
  }
}
