/// 세 가지 스타일의 영어 스크립트 모델
class ThreeStyleScript {
  final String formal; // 격식있는 스타일
  final String casual; // 편한 스타일
  final String witty; // 재치있는 스타일

  const ThreeStyleScript({
    required this.formal,
    required this.casual,
    required this.witty,
  });

  /// JSON에서 ThreeStyleScript 객체 생성
  factory ThreeStyleScript.fromJson(Map<String, dynamic> json) {
    return ThreeStyleScript(
      formal: json['formal'] as String? ?? '',
      casual: json['casual'] as String? ?? '',
      witty: json['witty'] as String? ?? '',
    );
  }

  /// ThreeStyleScript 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {'formal': formal, 'casual': casual, 'witty': witty};
  }

  /// 모든 스타일이 비어있지 않은지 확인
  bool get isValid =>
      formal.isNotEmpty && casual.isNotEmpty && witty.isNotEmpty;

  /// 스타일별 스크립트 목록 반환
  List<String> get allStyles => [formal, casual, witty];

  /// 스타일 이름과 스크립트의 맵 반환
  Map<String, String> get styleMap => {
    '격식있는': formal,
    '편한': casual,
    '재치있는': witty,
  };

  @override
  String toString() {
    return 'ThreeStyleScript(formal: $formal, casual: $casual, witty: $witty)';
  }
}
