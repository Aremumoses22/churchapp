// ──────────────────────────────────────────────────────────────────────────────
// BIBLE MODEL
// ──────────────────────────────────────────────────────────────────────────────

class BibleBook {
  const BibleBook({
    required this.name,
    required this.chapters,
    required this.isOldTestament,
  });

  final String name;
  final int chapters;
  final bool isOldTestament;
}
