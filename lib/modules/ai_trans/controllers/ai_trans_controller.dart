import 'package:flutter/material.dart';
import '../models/translation_result.dart';
import '../services/ai_trans_service.dart';

/// AI 번역 컨트롤러
class AiTransController extends ChangeNotifier {
  final AiTransService _aiTransService;

  AiTransController(this._aiTransService);

  bool _isTranslating = false;
  TranslationResult? _lastTranslation;
  String? _error;

  bool get isTranslating => _isTranslating;
  TranslationResult? get lastTranslation => _lastTranslation;
  String? get error => _error;

  /// 텍스트 번역
  Future<void> translateText({
    required String text,
    String sourceLang = 'en',
    String targetLang = 'ko',
  }) async {
    _isTranslating = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _aiTransService.translateText(
        text: text,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );

      if (result.isSuccess) {
        _lastTranslation = result.dataOrNull;
        _error = null;
      } else {
        _error = result.errorMessageOrNull ?? '번역에 실패했습니다.';
        _lastTranslation = null;
      }
    } catch (e) {
      _error = '번역 중 오류가 발생했습니다: $e';
      _lastTranslation = null;
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }

  /// 오류 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 마지막 번역 결과 초기화
  void clearLastTranslation() {
    _lastTranslation = null;
    notifyListeners();
  }
}
