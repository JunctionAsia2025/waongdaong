/// API 호출 결과를 나타내는 클래스
sealed class Result<T> {
  const Result();
  
  /// 성공 결과
  const factory Result.success(T data) = Success<T>;
  
  /// 실패 결과
  const factory Result.failure(String message, [Object? error]) = Failure<T>;
  
  /// 로딩 상태
  const factory Result.loading() = Loading<T>;
  
  /// 성공 여부 확인
  bool get isSuccess => this is Success<T>;
  
  /// 실패 여부 확인
  bool get isFailure => this is Failure<T>;
  
  /// 로딩 여부 확인
  bool get isLoading => this is Loading<T>;
  
  /// 성공 데이터 추출 (null 안전)
  T? get dataOrNull => switch (this) {
    Success(data: final data) => data,
    _ => null,
  };
  
  /// 에러 메시지 추출 (null 안전)
  String? get errorMessageOrNull => switch (this) {
    Failure(message: final message) => message,
    _ => null,
  };
  
  /// 성공 시 콜백 실행
  Result<T> onSuccess(Function(T) callback) {
    if (this is Success<T>) {
      callback((this as Success<T>).data);
    }
    return this;
  }
  
  /// 실패 시 콜백 실행
  Result<T> onFailure(Function(String, Object?) callback) {
    if (this is Failure<T>) {
      final failure = this as Failure<T>;
      callback(failure.message, failure.error);
    }
    return this;
  }
  
  /// 로딩 시 콜백 실행
  Result<T> onLoading(void Function() callback) {
    if (this is Loading<T>) {
      callback();
    }
    return this;
  }
}

/// 성공 결과
class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && other.data == data;
  }
  
  @override
  int get hashCode => data.hashCode;
  
  @override
  String toString() => 'Success(data: $data)';
}

/// 실패 결과
class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  
  const Failure(this.message, [this.error]);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure<T> && 
           other.message == message && 
           other.error == error;
  }
  
  @override
  int get hashCode => Object.hash(message, error);
  
  @override
  String toString() => 'Failure(message: $message, error: $error)';
}

/// 로딩 상태
class Loading<T> extends Result<T> {
  const Loading();
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Loading<T>;
  }
  
  @override
  int get hashCode => 0;
  
  @override
  String toString() => 'Loading()';
}
