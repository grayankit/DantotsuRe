import 'PlayerEngine.dart';

const _alternates = {
  'eng': ['en', 'english'],
  'spa': ['es', 'spanish', 'esp', 'latino'],
  'por': ['pt', 'portuguese'],
  'pob': ['pt-br', 'ptbr', 'brazilian'],
  'fre': ['fr', 'fra', 'french'],
  'ger': ['de', 'deu', 'german'],
  'ita': ['it', 'italian'],
  'rus': ['ru', 'russian'],
  'ara': ['ar', 'arabic'],
  'ind': ['id', 'indonesian'],
  'jpn': ['ja', 'jp', 'japanese'],
  'kor': ['ko', 'korean'],
  'chi': ['zh', 'zho', 'chinese'],
  'tur': ['tr', 'turkish'],
  'vie': ['vi', 'vietnamese'],
  'tha': ['th', 'thai'],
  'pol': ['pl', 'polish'],
  'dut': ['nl', 'nld', 'dutch'],
  'hin': ['hi', 'hindi'],
};

List<String> languageList(String text) => [
  for (final part in text.split(RegExp(r'[,;\n]')))
    if (part.trim().isNotEmpty) part.trim(),
];

Set<String> languageKeys(String name) {
  final wanted = name.trim().toLowerCase();
  final keys = {wanted};
  for (final entry in _alternates.entries) {
    final all = {entry.key, ...entry.value};
    if (all.contains(wanted) ||
        entry.value.last.startsWith(wanted) && wanted.length >= 3) {
      keys.addAll(all);
    }
  }
  return keys;
}

bool _matches(PlayerTrack track, Set<String> keys) {
  final language = (track.language ?? '').toLowerCase();
  if (language.isNotEmpty &&
      (keys.contains(language) ||
          keys.any((k) => language.startsWith('$k-')))) {
    return true;
  }
  final title = (track.title ?? '').toLowerCase();
  if (title.isEmpty) return false;
  final words = title.split(RegExp(r'[^a-z\-]+'));
  return keys.any((k) => k.length > 2 ? title.contains(k) : words.contains(k));
}

bool _forcedOrSigns(PlayerTrack track) {
  final title = (track.title ?? '').toLowerCase();
  return title.contains('sign') ||
      title.contains('song') ||
      title.contains('forced');
}

PlayerTrack? pickTrack(
  List<PlayerTrack> tracks,
  List<String> priority, {
  bool avoidSigns = false,
}) {
  for (final language in priority) {
    final keys = languageKeys(language);
    final found = tracks.where((t) => _matches(t, keys)).toList();
    if (found.isEmpty) continue;
    if (avoidSigns) {
      final full = found.where((t) => !_forcedOrSigns(t));
      if (full.isNotEmpty) return full.first;
    }
    return found.first;
  }
  return null;
}
