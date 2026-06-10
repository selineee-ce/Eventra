String normalizeSearchText(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

bool matchesSearchQuery(String query, Iterable<Object?> values) {
  final normalizedQuery = normalizeSearchText(query);
  if (normalizedQuery.isEmpty) return true;

  return values.any((value) {
    final text = normalizeSearchText(value?.toString() ?? '');
    return text.contains(normalizedQuery);
  });
}

int searchMatchScore(String query, Iterable<Object?> values) {
  final normalizedQuery = normalizeSearchText(query);
  if (normalizedQuery.isEmpty) return 0;

  var bestScore = -1;
  for (final value in values) {
    final text = normalizeSearchText(value?.toString() ?? '');
    if (text.isEmpty) continue;
    if (text == normalizedQuery) {
      bestScore = bestScore < 100 ? 100 : bestScore;
    } else if (text.startsWith(normalizedQuery)) {
      bestScore = bestScore < 80 ? 80 : bestScore;
    } else if (text.split(' ').contains(normalizedQuery)) {
      bestScore = bestScore < 65 ? 65 : bestScore;
    } else if (text.contains(normalizedQuery)) {
      bestScore = bestScore < 45 ? 45 : bestScore;
    }
  }

  return bestScore;
}

List<Object?> flattenSearchValues(Object? value) {
  final values = <Object?>[];

  void collect(Object? item) {
    if (item == null) return;
    if (item is Map) {
      for (final entry in item.entries) {
        collect(entry.value);
      }
      return;
    }
    if (item is Iterable && item is! String) {
      for (final child in item) {
        collect(child);
      }
      return;
    }
    values.add(item);
  }

  collect(value);
  return values;
}
