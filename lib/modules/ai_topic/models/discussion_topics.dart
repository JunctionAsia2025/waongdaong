/// 콘텐츠 기반 토론 주제 모델
class DiscussionTopics {
  final String topic1; // 첫 번째 토론 주제
  final String topic2; // 두 번째 토론 주제
  final String topic3; // 세 번째 토론 주제

  const DiscussionTopics({
    required this.topic1,
    required this.topic2,
    required this.topic3,
  });

  /// JSON에서 DiscussionTopics 객체 생성
  factory DiscussionTopics.fromJson(Map<String, dynamic> json) {
    return DiscussionTopics(
      topic1: json['topic1'] as String? ?? '',
      topic2: json['topic2'] as String? ?? '',
      topic3: json['topic3'] as String? ?? '',
    );
  }

  /// DiscussionTopics 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {'topic1': topic1, 'topic2': topic2, 'topic3': topic3};
  }

  /// 모든 토론 주제가 비어있지 않은지 확인
  bool get isValid =>
      topic1.isNotEmpty && topic2.isNotEmpty && topic3.isNotEmpty;

  /// 토론 주제 목록 반환
  List<String> get allTopics => [topic1, topic2, topic3];

  /// 번호와 함께 토론 주제 맵 반환
  Map<String, String> get topicMap => {
    '주제 1': topic1,
    '주제 2': topic2,
    '주제 3': topic3,
  };

  @override
  String toString() {
    return 'DiscussionTopics(topic1: $topic1, topic2: $topic2, topic3: $topic3)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiscussionTopics &&
        other.topic1 == topic1 &&
        other.topic2 == topic2 &&
        other.topic3 == topic3;
  }

  @override
  int get hashCode => topic1.hashCode ^ topic2.hashCode ^ topic3.hashCode;
}
