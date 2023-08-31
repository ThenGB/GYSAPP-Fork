extension StringExtensions on String {
  String capitalizeEachWord() {
    List<String> words = split(' ');
    final excludeWords = [
      'and',
      'the',
      'of',
      'in',
      'a',
      'an',
      'dan',
      'ke',
    ]; // Add more words as needed
    for (int i = 0; i < words.length; i++) {
      final lowerWord = words[i].toLowerCase();
      if (!excludeWords.contains(lowerWord)) {
        words[i] = words[i].capitalize();
      } else {
        words[i] = lowerWord; // Force excludedWords to lowercase in result
      }
    }
    return words.join(' ');
  }

  String capitalizeSentence() {
    if (isEmpty) return '';
    return replaceAllMapped(
        RegExp(r'(^|\. )\w'), (match) => match.group(0)!.toUpperCase());
  }

  String capitalize() {
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
