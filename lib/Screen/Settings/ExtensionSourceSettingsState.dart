import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/widgets.dart';

import '../../Model/Setting.dart';
import '../../Widgets/Components/ScreenState.dart';

class ExtensionSourceSettingsState extends ScreenState {
  final Extension extension;

  ExtensionSourceSettingsState(this.extension);

  String get title => extension.name;

  List<Setting> settings(BuildContext context) => [
    for (final s in extension.settings(context))
      Setting(
        type: SettingType.values.firstWhere((t) => t.name == s.type.name),
        name: s.name,
        description: s.description,
        icon: s.icon,
        iconWidget: s.iconWidget,
        isVisible: s.isVisible,
        isActivity: s.isActivity,
        isChecked: s.isChecked,
        trailingIcon: s.trailingIcon,
        onClick: s.onClick == null ? null : () => s.onClick!(),
        onLongClick: s.onLongClick == null ? null : () => s.onLongClick!(),
        onSwitchChange: s.onSwitchChange == null
            ? null
            : (v) => s.onSwitchChange!(v),
        attach: s.attach,
        minValue: s.minValue,
        maxValue: s.maxValue,
        initialValue: s.initialValue,
        onSliderChange: s.onSliderChange,
        onInputChange: s.onInputChange,
      ),
  ];
}
