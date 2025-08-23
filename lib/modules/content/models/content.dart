/// 학습 콘텐츠 모델
class Content {
  final String id;
  final String title;
  final String content;
  final String contentType;
  final String? sourceUrl;
  final String difficultyLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> categories;

  const Content({
    required this.id,
    required this.title,
    required this.content,
    required this.contentType,
    this.sourceUrl,
    required this.difficultyLevel,
    required this.createdAt,
    required this.updatedAt,
    this.categories = const [],
  });

  /// JSON에서 Content 생성
  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      contentType: json['content_type'] as String,
      sourceUrl: json['source_url'] as String?,
      difficultyLevel: json['difficulty_level'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      categories: json['categories'] != null 
          ? List<String>.from(json['categories'] as List)
          : [],
    );
  }

  /// Content를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'content_type': contentType,
      'source_url': sourceUrl,
      'difficulty_level': difficultyLevel,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'categories': categories,
    };
  }

  /// 콘텐츠 정보 복사 및 수정
  Content copyWith({
    String? id,
    String? title,
    String? content,
    String? contentType,
    String? sourceUrl,
    String? difficultyLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? categories,
  }) {
    return Content(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categories: categories ?? this.categories,
    );
  }

  /// 콘텐츠가 뉴스인지 확인
  bool get isNews => contentType == 'news';
  
  /// 콘텐츠가 논문인지 확인
  bool get isPaper => contentType == 'paper';
  
  /// 콘텐츠가 칼럼인지 확인
  bool get isColumn => contentType == 'column';
  
  /// 콘텐츠가 블로그인지 확인
  bool get isBlog => contentType == 'blog';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Content && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Content(id: $id, title: $title, type: $contentType)';
  }
}
