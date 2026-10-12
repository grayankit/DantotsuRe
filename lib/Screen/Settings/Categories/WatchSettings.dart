import 'package:flutter/material.dart';

import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Detail/Watch/Data/EpisodeMeta.dart';
import '../../Detail/Watch/Data/EpisodeMetaService.dart';
import '../../Detail/Watch/Data/WatchPrefs.dart';
import '../../../Model/Setting.dart';
import '../../../Utils/Extensions/ContextExtensions.dart';
import '../../../Utils/Functions/SnackBar.dart';
import '../../../Widgets/Components/AppControls.dart';
import '../../../Utils/Functions/NavigateToScreen.dart';
import '../SubSettingsScreen.dart';
import '../Widgets/SegmentedSetting.dart';
import 'PlayerSettings.dart';
import 'ReaderSettings.dart';

String metaProviderDescription(EpisodeMetaProvider provider) =>
    switch (provider.id) {
      'anizip' => getString.watchMetaAniZipDesc,
      'kitsu' => getString.watchMetaKitsuDesc,
      'simkl' => getString.watchMetaSimklDesc,
      'anilist' => getString.watchMetaAniListDesc,
      'tenrai' => getString.watchMetaTenraiDesc,
      _ => '',
    };

List<Setting> watchSettings(BuildContext context) => [
  Setting.normal(
    name: getString.settingsPlayer,
    description: getString.settingsPlayerDesc,
    icon: Icons.play_circle_outline_rounded,
    isActivity: true,
    onClick: () => navigateToPage(
      context,
      SubSettingsScreen(
        title: getString.settingsPlayer,
        settings: playerSettings,
      ),
    ),
  ),
  Setting.normal(
    name: getString.settingsReader,
    description: getString.settingsReaderDesc,
    icon: Icons.menu_book_rounded,
    isActivity: true,
    onClick: () => navigateToPage(
      context,
      SubSettingsScreen(
        title: getString.settingsReader,
        settings: readerSettings,
      ),
    ),
  ),
  Setting.header(getString.watchSettingsLayout),
  Setting.switchType(
    name: getString.watchResumeShelf,
    description: getString.watchResumeShelfDesc,
    icon: Icons.history_rounded,
    isChecked: watchResumeShelfPref.rx.value,
    onSwitchChange: (v) => watchResumeShelfPref.rx.value = v,
  ),
  segmentedSetting<int>(
    name: getString.watchLayout,
    description: getString.watchDefaultLayoutDesc,
    icon: Icons.view_list_rounded,
    label: getString.watchLayout,
    value: watchDefaultViewPref.rx.value,
    onChanged: (v) => watchDefaultViewPref.rx.value = v,
    segments: [
      const AppSegment(0, icon: Icons.view_list_rounded),
      const AppSegment(1, icon: Icons.grid_view_rounded),
      const AppSegment(2, icon: Icons.view_comfy_rounded),
    ],
  ),
  segmentedSetting<int>(
    name: getString.watchChunkSize,
    description: getString.watchChunkSizeDesc,
    icon: Icons.format_list_numbered_rounded,
    label: getString.watchChunkSize,
    value: watchChunkSizePref.rx.value,
    onChanged: (v) => watchChunkSizePref.rx.value = v,
    segments: const [
      AppSegment(20, label: '20'),
      AppSegment(30, label: '30'),
      AppSegment(50, label: '50'),
      AppSegment(100, label: '100'),
    ],
  ),
  Setting.switchType(
    name: getString.watchShowDescription,
    description: getString.watchShowDescriptionDesc,
    icon: Icons.notes_rounded,
    isChecked: watchShowDescriptionPref.rx.value,
    onSwitchChange: (v) => watchShowDescriptionPref.rx.value = v,
  ),
  Setting.switchType(
    name: getString.watchShowFiller,
    description: getString.watchShowFillerDesc,
    icon: Icons.filter_list_rounded,
    isChecked: watchShowFillerPref.rx.value,
    onSwitchChange: (v) => watchShowFillerPref.rx.value = v,
  ),
  Setting.switchType(
    name: getString.watchBlurUnwatched,
    description: getString.watchBlurUnwatchedDesc,
    icon: Icons.blur_on_rounded,
    isChecked: watchBlurUnwatchedPref.rx.value,
    onSwitchChange: (v) => watchBlurUnwatchedPref.rx.value = v,
  ),
  Setting.switchType(
    name: getString.watchMarkOnLongPress,
    description: getString.watchMarkOnLongPressDesc,
    icon: Icons.touch_app_rounded,
    isChecked: watchMarkOnLongPressPref.rx.value,
    onSwitchChange: (v) => watchMarkOnLongPressPref.rx.value = v,
  ),
  Setting.header(getString.watchSettingsSources),
  segmentedSetting<String>(
    name: getString.trackProgressSettingAnime,
    description: getString.trackProgressSettingDesc,
    icon: Icons.play_circle_outline_rounded,
    label: getString.trackProgressSettingAnime,
    value: trackAnimePref.rx.value,
    onChanged: (v) => trackAnimePref.rx.value = v,
    segments: [
      AppSegment('ask', label: getString.trackProgressAsk),
      AppSegment('always', label: getString.trackProgressAlways),
      AppSegment('never', label: getString.trackProgressLocal),
      AppSegment('off', label: getString.trackProgressOff),
    ],
  ),
  segmentedSetting<String>(
    name: getString.trackProgressSettingManga,
    description: getString.trackProgressSettingDesc,
    icon: Icons.menu_book_rounded,
    label: getString.trackProgressSettingManga,
    value: trackMangaPref.rx.value,
    onChanged: (v) => trackMangaPref.rx.value = v,
    segments: [
      AppSegment('ask', label: getString.trackProgressAsk),
      AppSegment('always', label: getString.trackProgressAlways),
      AppSegment('never', label: getString.trackProgressLocal),
      AppSegment('off', label: getString.trackProgressOff),
    ],
  ),
  segmentedSetting<String>(
    name: getString.watchMatching,
    description: getString.watchMatchingDesc,
    icon: Icons.search_rounded,
    label: getString.watchMatching,
    value: watchAutoMatchPref.rx.value,
    onChanged: (v) => watchAutoMatchPref.rx.value = v,
    segments: [
      AppSegment('closest', label: getString.watchMatchClosest),
      AppSegment('exact', label: getString.watchMatchExact),
    ],
  ),
  Setting.header(getString.watchSettingsMetadata),
  Setting.custom(
    name: getString.watchSettingsMetadata,
    description: getString.watchMetadataDesc,
    builder: (context) => const _MetaProviders(),
  ),
  Setting.normal(
    name: getString.watchClearMetadata,
    description: getString.watchClearMetadataDesc,
    icon: Icons.cleaning_services_rounded,
    onClick: () {
      EpisodeMetaService.clearCache();
      snackString(getString.watchMetadataCleared);
    },
  ),
];

class _MetaProviders extends StatelessWidget {
  const _MetaProviders();

  @override
  Widget build(BuildContext context) => Watch(() {
    watchMetaDisabledPref.rx.value;
    final list = EpisodeMetaService.ordered();
    return ReorderableListView(
      shrinkWrap: true,
      buildDefaultDragHandles: false,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (from, to) {
        final ids = [for (final p in list) p.id];
        final moved = ids.removeAt(from);
        ids.insert(to > from ? to - 1 : to, moved);
        EpisodeMetaService.setOrder(ids);
        EpisodeMetaService.clearCache();
      },
      children: [
        for (var i = 0; i < list.length; i++) _row(context, list[i], i),
      ],
    );
  });

  Widget _row(BuildContext context, EpisodeMetaProvider provider, int index) {
    final scheme = context.colorScheme;
    return SwitchListTile(
      key: ValueKey(provider.id),
      contentPadding: EdgeInsets.zero,
      secondary: ReorderableDragStartListener(
        index: index,
        child: Icon(Icons.drag_indicator_rounded, color: scheme.outline),
      ),
      title: Text(provider.name),
      subtitle: Text(
        metaProviderDescription(provider),
        style: context.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      value: EpisodeMetaService.enabled(provider.id),
      onChanged: (on) {
        EpisodeMetaService.setEnabled(provider.id, on);
        EpisodeMetaService.clearCache();
      },
    );
  }
}
