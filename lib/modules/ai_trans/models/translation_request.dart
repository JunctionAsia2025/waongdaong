class TranslationRequest {
  final String text;
  final String sourceLang;
  final String targetLang;

  const TranslationRequest({
    required this.text,
    this.sourceLang = 'en',
    this.targetLang = 'ko',
  });

  Map<String, dynamic> toJson() {
    return {'text': text, 'source_lang': sourceLang, 'target_lang': targetLang};
  }

  factory TranslationRequest.fromJson(Map<String, dynamic> json) {
    return TranslationRequest(
      text: json['text'] as String,
      sourceLang: json['source_lang'] as String? ?? 'en',
      targetLang: json['target_lang'] as String? ?? 'ko',
    );
  }
}
