import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 파일 스토리지 관련 기능을 담당하는 서비스
class StorageService {
  StorageService();

  /// Supabase 클라이언트
  SupabaseClient get _client => Supabase.instance.client;

  /// 파일 업로드
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List fileBytes,
    String? contentType,
    Map<String, String>? metadata,
  }) async {
    try {
      final response = await _client.storage
          .from(bucket)
          .uploadBinary(
            path,
            fileBytes,
            fileOptions: FileOptions(contentType: contentType, upsert: false),
          );

      return response;
    } catch (e) {
      throw StorageException('파일 업로드 실패: $e');
    }
  }

  /// 파일 다운로드
  Future<Uint8List> downloadFile({
    required String bucket,
    required String path,
  }) async {
    try {
      final response = await _client.storage.from(bucket).download(path);

      return response;
    } catch (e) {
      throw StorageException('파일 다운로드 실패: $e');
    }
  }

  /// 파일 URL 생성
  String getPublicUrl({required String bucket, required String path}) {
    try {
      return _client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      throw StorageException('공개 URL 생성 실패: $e');
    }
  }

  /// 서명된 URL 생성 (만료 시간 설정 가능)
  Future<String> getSignedUrl({
    required String bucket,
    required String path,
    int expiresIn = 3600, // 1시간
  }) async {
    try {
      final response = await _client.storage
          .from(bucket)
          .createSignedUrl(path, expiresIn);

      return response;
    } catch (e) {
      throw StorageException('서명된 URL 생성 실패: $e');
    }
  }

  /// 파일 삭제
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _client.storage.from(bucket).remove([path]);
    } catch (e) {
      throw StorageException('파일 삭제 실패: $e');
    }
  }

  /// 버킷의 파일 목록 조회
  Future<List<FileObject>> listFiles({
    required String bucket,
    String? path,
  }) async {
    try {
      return await _client.storage.from(bucket).list(path: path);
    } catch (e) {
      throw StorageException('파일 목록 조회 실패: $e');
    }
  }
}

/// 스토리지 예외 클래스
class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
