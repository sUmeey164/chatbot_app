// lib/title_generator.dart // Renamed file
class TitleGenerator {
  // Renamed class
  static String generate(String firstMessage) {
    // Renamed method and parameter
    if (firstMessage.isEmpty) {
      return "New Chat"; // Translated string literal
    }
    // Take the first 30 characters of the first message and trim whitespace
    String title =
        firstMessage.length >
            30 // Renamed variable
        ? firstMessage.substring(0, 30) + '...'
        : firstMessage;
    return title.trim(); // Renamed variable
  }
}
