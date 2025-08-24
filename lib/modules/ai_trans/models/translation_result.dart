class TranslationResult {
  final String originalText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final DateTime timestamp;

  const TranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'original_text': originalText,
      'translated_text': translatedText,
      'source_lang': sourceLang,
      'target_lang': targetLang,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TranslationResult.fromJson(Map<String, dynamic> json) {
    return TranslationResult(
      originalText: json['original_text'] as String,
      translatedText: json['translated_text'] as String,
      sourceLang: json['source_lang'] as String,
      targetLang: json['target_lang'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
