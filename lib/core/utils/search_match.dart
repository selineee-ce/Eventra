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
