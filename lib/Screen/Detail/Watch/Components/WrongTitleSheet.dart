import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../Core/State/State.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../Data/SourceMatcher.dart';
import '../../../../Utils/Extensions/Responsive.dart';
import '../../../../Utils/Functions/NavigateToScreen.dart';
import '../../../../Widgets/Components/AppSheet.dart';
import '../../../../Widgets/Shelf/MediaSection.dart';
import '../../../../Core/Services/Model/Anime.dart';
import '../../../../Core/Services/Model/Manga.dart';
import '../../../../Core/Services/Model/Media.dart';
import '../WatchState.dart';

class WrongTitleSheet extends StatefulWidget {
  final WatchState state;

  const WrongTitleSheet({super.key, required this.state});

  @override
  State<WrongTitleSheet> createState() => _WrongTitleSheetState();
}

class _WrongTitleSheetState extends State<WrongTitleSheet> {
  late final TextEditingController _term = TextEditingController(
    text: widget.state.current.mainName,
  );
  final _results = <SourceMatch>[].liveList;
  final _loading = false.live;
  final _error = Live<String?>(null);
  int _run = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_search());
  }

  @override
  void dispose() {
    _run++;
    _term.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final source = widget.state.source.value;
    final term = _term.text.trim();
    if (source == null || term.isEmpty) return;
    final run = ++_run;
    _loading.value = true;
    _error.value = null;
    try {
      final found = await SourceMatcher.search(
        source,
        term,
        SourceMatcher.names(widget.state.current),
      );
      if (run != _run) return;
      _results.value = found;
    } catch (e) {
      if (run != _run) return;
      _error.value = e.toString();
      _results.clear();
    } finally {
      if (run == _run) _loading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      title: getString.watchWrongTitle,
      heightFactor: 0.8,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              Dimens.pagePad,
              0,
              Dimens.pagePad,
              Dimens.gapSm,
            ),
            child: TextField(
              controller: _term,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: getString.watchSearchSource(
                  widget.state.source.value?.name ?? '',
                ),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  onPressed: _search,
                ),
              ),
            ),
          ),
          Expanded(
            child: Watch(() {
              if (_loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final message = _error.value;
              if (message != null) {
                return Center(
                  child: Text(message, textAlign: TextAlign.center),
                );
              }
              if (_results.isEmpty) {
                return Center(child: Text(getString.watchNothingFound));
              }
              final items = _results.toList();
              final anime = widget.state.anime;
              return SingleChildScrollView(
                child: MediaSection(
                  data: MediaSectionData(
                    type: 0,
                    title: getString.watchResults,
                    fullPage: false,
                    mediaList: [
                      for (final m in items)
                        Media(
                          id: '${m.media.url}',
                          name: m.media.title,
                          nameRomaji: m.media.title,
                          userPreferredName: m.media.title,
                          cover: m.media.cover,
                          shareLink: m.media.url ?? '',
                          relation: '${m.score}%',
                          minimal: true,
                          anime: anime ? Anime() : null,
                          manga: anime ? null : Manga(),
                        ),
                    ],
                    onMediaTap: (ctx, index, media, tag) {
                      popPage(context);
                      unawaited(widget.state.chooseMatch(items[index].media));
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
