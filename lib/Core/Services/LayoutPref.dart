import '../Preferences/PrefManager.dart';

Pref<Map<String, bool>> layoutPref(String key, Map<String, bool> defaults) =>
    Pref<Map<String, bool>>.coded(
      key,
      defaults,
      PrefLocation.OTHER,
      encode: (v) => Map<String, dynamic>.from(v),
      decode: (raw) => raw is Map
          ? {for (final e in raw.entries) e.key.toString(): e.value == true}
          : defaults,
    );

List<T> applyLayout<T>(
  List<T> all,
  String Function(T) titleOf,
  Map<String, bool> layout,
) {
  final byTitle = {for (final item in all) titleOf(item): item};
  return [
    for (final e in layout.entries)
      if (e.value && byTitle.containsKey(e.key)) byTitle[e.key]!,
    for (final item in all)
      if (!layout.containsKey(titleOf(item))) item,
  ];
}
