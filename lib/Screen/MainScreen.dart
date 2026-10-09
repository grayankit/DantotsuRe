import 'package:flutter/material.dart';

import '../Core/Services/MediaServiceController.dart';
import '../Core/ThemeManager/CardStyleController.dart';
import '../Utils/Extensions/ContextExtensions.dart';
import '../Widgets/Components/BaseScreen.dart';
import 'Feed/FeedTabs.dart';
import 'Navbar.dart';
import '../Api/Discord/DiscordPresence.dart';
import '../Core/State/State.dart';
import '../Utils/Nav/DpadLayers.dart';
import '../Widgets/Components/ScreenState.dart';
import 'MainState.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends BaseScreen<MainScreen>
    with ScreenStateHost<MainScreen, MainState> {
  @override
  MainState buildState() => MainState(onPresenceChanged: refreshPresence);

  MediaServiceController get _services => state.services;

  @override
  DiscordPresence? get presence => state.presence;

  Widget get _navbar => Watch(() {
    final service = _services.currentService.value;
    final tabs = feedTabsFor(service);
    return FloatingBottomNavBar(
      laneKey: shellLaneKey,
      selectedIndex: state.tab.value.clamp(0, tabs.length - 1),
      items: [
        for (final (i, t) in tabs.indexed)
          NavItem(index: i, icon: t.icon, label: t.label.toUpperCase()),
      ],
      onTabSelected: state.select,
    );
  });

  @override
  Widget buildContent(BuildContext context) {
    final body = Watch(() {
      final service = _services.currentService.value;
      final tabs = feedTabsFor(service);
      final index = state.tab.value.clamp(0, tabs.length - 1);
      return IndexedStack(
        index: index,
        children: [
          for (final (i, t) in tabs.indexed)
            state.built.contains(i)
                ? KeyedSubtree(
                    key: ValueKey('${service.id}-$i-${t.type?.name}'),
                    child: Watch(() {
                      if (i == index) find<CardStyleController>().epoch.value;
                      return t.build(service);
                    }),
                  )
                : const SizedBox.shrink(),
        ],
      );
    });

    return Stack(
      children: [
        Row(
          children: [
            if (!context.isPhone) SizedBox(width: 100, child: _navbar),
            Expanded(child: body),
          ],
        ),
        if (context.isPhone) _navbar,
      ],
    );
  }
}
