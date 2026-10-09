import 'dart:async';

import 'package:dartotsu_extension_bridge/Extensions/DownloadablePlugin.dart';
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/material.dart';

import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Utils/Extensions/ContextExtensions.dart';
import '../../Utils/Functions/NavigateToScreen.dart';
import '../../Utils/Functions/SnackBar.dart';
import '../../Utils/Nav/DpadNav.dart';
import '../../Widgets/Components/AlertDialogBuilder.dart';
import '../../Widgets/Components/AppBars.dart';
import '../../Widgets/Components/BaseScreen.dart';
import '../../Widgets/Components/CustomBottomDialog.dart';
import '../../Widgets/Components/LoadSvg.dart';
import '../../Widgets/Components/ThemedContainer.dart';
import 'ExtensionList.dart';
import 'Widgets/ExtensionManagerSheet.dart';
import '../../Widgets/Components/AppTabs.dart';
import '../../Api/Discord/DiscordPresence.dart';
import '../../Core/State/State.dart';
import '../../Utils/Extensions/StringExtensions.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'ExtensionBrowserState.dart';

class ExtensionScreen extends StatefulWidget {
  const ExtensionScreen({super.key});

  @override
  State<ExtensionScreen> createState() => ExtensionScreenState();
}

class ExtensionScreenState extends BaseScreen<ExtensionScreen>
    with
        TickerProviderStateMixin,
        ScreenStateHost<ExtensionScreen, ExtensionBrowserState> {
  @override
  ExtensionBrowserState buildState() => ExtensionBrowserState();

  ExtensionManager get manager => state.manager;

  @override
  DiscordPresence? get presence => state.presence;

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: DpadLane(
          laneKey: state.appBarLaneKey,
          verticalEdge: DpadEdgeBehavior.stop,
          onEdge: state.onAppBarEdge,
          child: AppScreenBar(
            title: getString.extension(2),
            actions: [
              Row(children: [..._buildActions(), const SizedBox(width: 8)]),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          DpadLane(
            laneKey: state.tabsLaneKey,
            verticalEdge: DpadEdgeBehavior.stop,
            onEdge: state.onTabsEdge,
            child: Watch(
              () => AppTabBar(
                controller: state.tabs,
                onFocusChange: state.onTabFocus,
                tabs: _buildTabs(context),
              ),
            ),
          ),
          const SizedBox(height: 8),
          DpadLane(
            laneKey: state.searchLaneKey,
            verticalEdge: DpadEdgeBehavior.stop,
            onEdge: state.onSearchEdge,
            child: _searchBar(),
          ),
          Watch(
            () => Expanded(
              child: TabBarView(
                controller: state.tabs,
                children: _buildTabViews(state.searchQuery.value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    var theme = Theme.of(context).colorScheme;
    return [
      _buildServiceManager(),
      _buildRepoManager(),
      IconButton(
        icon: Icon(Icons.language_rounded, color: theme.primary),
        onPressed: state.chooseLanguages,
      ),
    ];
  }

  Widget _buildServiceManager() {
    return AnimatedBuilder(
      animation: state.tabs,
      builder: (_, _) {
        final type = state.currentType;

        return Watch(() {
          final currentManager = manager[type];

          return IconButton(
            icon: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                currentManager.icon,
                width: 24,
                height: 24,
                fit: BoxFit.cover,
              ),
            ),
            onPressed: () => showExtensionManagerSheet(context, type),
          );
        });
      },
    );
  }

  Widget _buildRepoManager() {
    var theme = Theme.of(context).colorScheme;
    return IconButton(
      icon: loadSvg(
        "assets/svg/github.svg",
        width: 24,
        height: 24,
        color: theme.primary,
      ),
      onPressed: () {
        final type = state.currentType;
        showCustomBottomDialog(
          context,
          CustomBottomDialog(
            title: getString.repositoriesTitle(type.name.capitalizeFirst),
            positiveText: getString.ok,
            positiveCallback: () => popPage(context),
            negativeText: getString.addRepository,
            negativeCallback: () => state.addRepository(type),
            viewList: [
              // Some repos (e.g. Kotatsu's shared parsers jar) are large
              // enough that a bare "Add Repository" tap with no feedback
              // looks hung - show real progress when the backend reports
              // it, an indeterminate bar otherwise. Styled to match the
              // plugin-install card in showInstallDialog below, so this
              // reads as the same "downloading" affordance everywhere in
              // the app rather than a one-off widget.
              Watch(() {
                final extension = manager[type];
                final loading = extension.state(type).loadingRepo.value;
                final progress = extension.state(type).repoLoadProgress.value;
                final scheme = Theme.of(context).colorScheme;
                final textStyle = Theme.of(context).textTheme.labelMedium;

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1,
                      child: child,
                    ),
                  ),
                  child: !loading
                      ? const SizedBox.shrink(key: ValueKey('idle'))
                      : Padding(
                          key: const ValueKey('loading'),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: context.cardColor,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: scheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cloud_download_rounded,
                                  color: scheme.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        getString.downloadingRepository,
                                        style: textStyle?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 6,
                                          backgroundColor: scheme.primary
                                              .withValues(alpha: 0.12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (progress != null) ...[
                                  const SizedBox(width: 12),
                                  Text(
                                    "${(progress * 100).toStringAsFixed(0)}%",
                                    style: textStyle?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: scheme.primary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                );
              }),
              Watch(() {
                final extension = manager[type];
                final repos = extension.state(type).repos.value;
                final active = extension.state(type).activeRepo.value;

                if (repos.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text(getString.noRepositories)),
                  );
                }

                return Column(
                  children: repos.map((repo) {
                    final selected = active?.url == repo.url;

                    return ThemedContainer(
                      blur: false,
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 8,
                      ),

                      color: selected ? theme.surfaceContainerHigh : null,
                      child: Material(
                        type: MaterialType.transparency,
                        child: ListTile(
                          hoverColor: Colors.transparent,

                          onTap: () async {
                            if (!selected) await state.selectRepo(type, repo);
                          },
                          leading: repo.iconUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    repo.iconUrl!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        const Icon(Icons.storage_rounded),
                                  ),
                                )
                              : loadSvg(
                                  "assets/svg/github.svg",
                                  color: theme.primary,
                                ),

                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  repo.name ??
                                      Uri.tryParse(repo.url)?.host ??
                                      repo.url,
                                  style: context.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                repo.url,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                getString.repoExtensionsCount(
                                  repo.extensions ?? '?',
                                ),
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: theme.primary,
                                ),
                              ),
                            ],
                          ),

                          trailing: IconButton(
                            icon: const Icon(Icons.delete_rounded),
                            onPressed: () async {
                              await state.removeRepo(type, repo.url);
                            },
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _searchBar() {
    final theme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ThemedContainer(
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: TextField(
          controller: state.textController,
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: getString.searchExtensions,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: theme.onSurfaceVariant,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
            filled: false,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          onChanged: state.onSearchChanged,
        ),
      ),
    );
  }

  List<Widget> _buildTabs(BuildContext context) {
    final tabs = <Widget>[];
    var index = 0;
    for (final type in ExtensionBrowserState.tabOrder) {
      final installedIndex = index++;
      tabs.add(
        Watch(
          () => AppTab(
            label: getString.installedType(type.name),
            count: state.count(type, installed: true),
            selected: state.currentIndex.value == installedIndex,
            focused: kFocused(state.focusedTabIndex.value == installedIndex),
          ),
        ),
      );
      final availableIndex = index++;
      tabs.add(
        Watch(
          () => AppTab(
            label: getString.availableType(type.name),
            count: state.count(type, installed: false),
            selected: state.currentIndex.value == availableIndex,
            focused: kFocused(state.focusedTabIndex.value == availableIndex),
          ),
        ),
      );
    }
    return tabs;
  }

  List<Widget> _buildTabViews(String query) {
    final views = <Widget>[];

    for (final type in ExtensionBrowserState.tabOrder) {
      final manager = this.manager[type].state(type);

      final installed = manager.installed.value;
      final available = manager.available.value;

      views.add(
        installed.isEmpty
            ? _emptyMessage(getString.noInstalledExtensions(type.name))
            : ExtensionList(
                itemType: type,
                isInstalled: true,
                searchQuery: query,
                onFirstRowUp: state.focusSearch,
                firstRowKey: state.firstRowKeys[views.length],
              ),
      );

      views.add(
        manager.loadingAvailable.value
            ? const Center(
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(),
                ),
              )
            : available.isEmpty
            ? _emptyMessage(getString.noAvailableExtensions(type.name))
            : ExtensionList(
                itemType: type,
                isInstalled: false,
                searchQuery: query,
                onFirstRowUp: state.focusSearch,
                firstRowKey: state.firstRowKeys[views.length],
              ),
      );
    }

    return views;
  }

  Widget _emptyMessage(String message) {
    final theme = Theme.of(context).colorScheme;
    return Center(
      child: Text(
        message,
        style: context.textTheme.bodyMedium?.copyWith(color: theme.onSurface),
      ),
    );
  }
}

void showDeleteDialog(
  BuildContext context,
  DownloadablePlugin plugin,
  String name,
) {
  AlertDialogBuilder(context)
    ..setTitle(getString.deletePluginTitle(name))
    ..setMessage(getString.deletePluginMessage)
    ..setPositiveButton(getString.yes, () async {
      await plugin.delete();
      snackString(getString.pluginDeleted(name));
    })
    ..setNegativeButton(getString.no, () {})
    ..show();
}

Future<void> showInstallDialog(
  BuildContext context,
  DownloadablePlugin plugin,
  String name,
) async {
  Map<String, dynamic>? remote;

  var hasUpdate = false;
  try {
    remote = await plugin.fetchRemote();
    if (remote == null) {
      snackString(getString.pluginNotInRepo(name));
      return;
    }
    if (plugin.installed.value) hasUpdate = await plugin.checkForUpdate();
  } catch (_) {
    snackString(getString.pluginFetchFailed);
    return;
  }

  if (!context.mounted) return;
  final scheme = context.colorScheme;
  final textStyle = Theme.of(context).textTheme.labelMedium;

  final version = remote["versionName"] ?? "";
  final sizeBytes = remote["fileSize"] ?? 0;
  final sizeMB = plugin.formatSize(sizeBytes);
  final description = remote["description"] ?? "";
  final author = remote["author"] ?? "";

  unawaited(
    showCustomBottomDialog(
      context,
      CustomBottomDialog(
        title: getString.installPluginTitle(name),
        viewList: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                version,
                style: textStyle?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: scheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Watch(() {
                final downloading = plugin.downloading.value;
                final progress = plugin.progress.value;

                if (downloading) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${(progress * 100).toStringAsFixed(1)}%",
                        style: textStyle?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.storage_rounded,
                          size: 16,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(getString.sizeLabel(sizeMB), style: textStyle),
                        const SizedBox(width: 16),
                        if (author.isNotEmpty) ...[
                          Icon(
                            Icons.person_rounded,
                            size: 16,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              author,
                              style: textStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        description,
                        style: textStyle?.copyWith(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
        ],
        negativeText: getString.cancel,
        positiveText: !plugin.installed.value
            ? getString.install
            : hasUpdate
            ? getString.update
            : getString.installedState,
        negativeCallback: () {
          popPage(context);
        },
        positiveCallback: () async {
          if (plugin.installed.value && !hasUpdate) {
            return;
          }

          if (plugin.downloading.value) return;

          await plugin.download();
          if (!context.mounted) return;
          if (plugin.installed.value) {
            popPage(context);
          }
        },
      ),
    ),
  );
}
