import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/result.dart';
import '../models/study_group.dart';
import '../../ai_topic/models/discussion_topics.dart';
import '../../ai_topic/ai_topic_module.dart';
import '../../content/services/content_service.dart';

class StudyService {
  final SupabaseClient _supabase;
  final ContentService _contentService;

  StudyService(this._supabase, this._contentService);

  /// 스터디그룹 생성
  Future<Result<StudyGroup>> createStudyGroup({
    required String title,
    required int maxParticipants,
    required DateTime startTime,
    required DateTime endTime,
    required String topic,
    required String createdBy,
  }) async {
    try {
      final groupData = {
        'title': title,
        'max_participants': maxParticipants,
        'current_participants': 1, // 생성자 포함
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'status': 'active',
        'topic': topic,
        'created_by': createdBy,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase
              .from('study_groups')
              .insert(groupData)
              .select()
              .single();

      return Result.success(StudyGroup.fromJson(response));
    } catch (e) {
      return Result.failure('스터디그룹 생성 중 오류가 발생했습니다.', e);
    }
  }

  /// 스터디그룹 종료
  Future<Result<void>> endStudyGroup({required String groupId}) async {
    try {
      await _supabase
          .from('study_groups')
          .update({
            'status': 'ended',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', groupId);

      return const Result.success(null);
    } catch (e) {
      return Result.failure('스터디그룹 종료 중 오류가 발생했습니다.', e);
    }
  }

  /// 스터디 그룹 정보 수정
  Future<Result<StudyGroup>> updateStudyGroup({
    required String groupId,
    String? name,
    String? description,
    String? category,
    int? maxMembers,
    String? meetingTime,
    String? meetingLocation,
    String? status,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) {
        updateData['name'] = name;
      }
      if (description != null) {
        updateData['description'] = description;
      }
      if (category != null) {
        updateData['category'] = category;
      }
      if (maxMembers != null) {
        updateData['max_members'] = maxMembers;
      }
      if (meetingTime != null) {
        updateData['meeting_time'] = meetingTime;
      }
      if (meetingLocation != null) {
        updateData['meeting_location'] = meetingLocation;
      }
      if (status != null) {
        updateData['status'] = status;
      }

      final response =
          await _supabase
              .from('study_groups')
              .update(updateData)
              .eq('id', groupId)
              .select()
              .single();

      final group = StudyGroup.fromJson(response);
      return Result.success(group);
    } catch (e) {
      return Result.failure('스터디 그룹을 수정하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 스터디 그룹 삭제
  Future<Result<void>> deleteStudyGroup(String groupId) async {
    try {
      await _supabase.from('study_groups').delete().eq('id', groupId);

      return const Result.success(null);
    } catch (e) {
      return Result.failure('스터디 그룹을 삭제하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 스터디 그룹 상세 조회
  Future<Result<StudyGroup>> getStudyGroup(String groupId) async {
    try {
      final response =
          await _supabase
              .from('study_groups')
              .select()
              .eq('id', groupId)
              .single();

      final group = StudyGroup.fromJson(response);
      return Result.success(group);
    } catch (e) {
      return Result.failure('스터디 그룹을 조회하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 스터디 그룹 목록 조회 (페이지네이션 + 필터링)
  Future<Result<List<StudyGroup>>> getStudyGroups({
    String? category,
    String? status,
    String? searchQuery,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      var query = _supabase.from('study_groups').select();

      // 필터링 적용
      if (category != null) {
        query = query.eq('category', category);
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'name.ilike.%$searchQuery%,description.ilike.%$searchQuery%',
        );
      }

      // 정렬 및 페이지네이션 적용
      final response = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      final groups =
          (response as List).map((json) => StudyGroup.fromJson(json)).toList();

      return Result.success(groups);
    } catch (e) {
      return Result.failure('스터디 그룹 목록을 조회하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자가 속한 스터디 그룹 목록 조회
  Future<Result<List<StudyGroup>>> getUserStudyGroups({
    required String userId,
    String? status,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      // 스터디 그룹 멤버십을 통해 사용자가 속한 그룹 조회
      final membershipsResponse = await _supabase
          .from('study_group_members')
          .select('group_id')
          .eq('user_id', userId);

      if (membershipsResponse.isEmpty) {
        return const Result.success([]);
      }

      final groupIds =
          (membershipsResponse as List)
              .map((item) => item['group_id'] as String)
              .toList();

      var query = _supabase
          .from('study_groups')
          .select()
          .inFilter('id', groupIds);

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      final groups =
          (response as List).map((json) => StudyGroup.fromJson(json)).toList();

      return Result.success(groups);
    } catch (e) {
      return Result.failure('사용자 스터디 그룹을 조회하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 스터디 그룹 자유 참여 (승인 불필요)
  Future<Result<void>> joinStudyGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      // 그룹 정원 확인만
      final groupResponse =
          await _supabase
              .from('study_groups')
              .select('max_members, status')
              .eq('id', groupId)
              .single();

      if (groupResponse['status'] != 'active') {
        return Result.failure('현재 참여할 수 없는 그룹입니다.', null);
      }

      final currentMembersResponse = await _supabase
          .from('study_group_members')
          .select('id')
          .eq('group_id', groupId)
          .eq('status', 'active');

      final currentMemberCount = (currentMembersResponse as List).length;
      final maxMembers = groupResponse['max_members'] as int;

      if (currentMemberCount >= maxMembers) {
        return Result.failure('그룹 정원이 가득 찼습니다.', null);
      }

      // 이미 가입된 사용자인지 확인
      final existingMembership =
          await _supabase
              .from('study_group_members')
              .select('id')
              .eq('group_id', groupId)
              .eq('user_id', userId)
              .maybeSingle();

      if (existingMembership != null) {
        return Result.failure('이미 가입된 그룹입니다.', null);
      }

      // 바로 가입 (승인 과정 없음)
      final membershipData = {
        'group_id': groupId,
        'user_id': userId,
        'status': 'active', // 바로 active 상태
        'joined_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('study_group_members').insert(membershipData);

      return const Result.success(null);
    } catch (e) {
      return Result.failure('스터디 그룹 참여 중 오류가 발생했습니다.', e);
    }
  }

  /// 스터디 그룹 탈퇴
  Future<Result<void>> leaveStudyGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _supabase
          .from('study_group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);

      return const Result.success(null);
    } catch (e) {
      return Result.failure('스터디 그룹 탈퇴 중 오류가 발생했습니다.', e);
    }
  }

  /// 스터디 그룹 멤버 목록 조회 (단순화)
  Future<Result<List<Map<String, dynamic>>>> getStudyGroupMembers({
    required String groupId,
    int page = 0,
    int pageSize = 50,
  }) async {
    try {
      final response = await _supabase
          .from('study_group_members')
          .select('''
            id,
            user_id,
            joined_at,
            users!inner(
              id,
              email,
              nickname,
              current_level
            )
          ''')
          .eq('group_id', groupId)
          .eq('status', 'active')
          .order('joined_at', ascending: true)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      final members =
          (response as List)
              .map(
                (json) => {
                  'membership_id': json['id'],
                  'user_id': json['user_id'],
                  'joined_at': json['joined_at'],
                  'user': json['users'],
                },
              )
              .toList();

      return Result.success(members);
    } catch (e) {
      return Result.failure('그룹 멤버를 조회하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 짧은 토론 세션 시작 (10-20분)
  Future<Result<Map<String, dynamic>>> startShortDiscussion({
    required String groupId,
    required String topic,
    required int duration, // 10, 15, 20분
  }) async {
    try {
      // 스터디그룹의 토픽을 업데이트
      final response =
          await _supabase
              .from('study_groups')
              .update({
                'topic': topic,
                'status': 'in_progress',
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', groupId)
              .select()
              .single();

      return Result.success(response);
    } catch (e) {
      return Result.failure('토론 세션을 시작하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 토론 세션 종료
  Future<Result<void>> endDiscussionSession({
    required String groupId,
    required int actualDuration,
  }) async {
    try {
      await _supabase
          .from('study_groups')
          .update({
            'status': 'completed',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', groupId);

      return const Result.success(null);
    } catch (e) {
      return Result.failure('토론 세션을 종료하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 스터디 그룹 통계 조회 (단순화)
  Future<Result<Map<String, dynamic>>> getStudyGroupStats(
    String groupId,
  ) async {
    try {
      // 총 멤버 수
      final totalMembersResponse = await _supabase
          .from('study_group_members')
          .select('id')
          .eq('group_id', groupId)
          .eq('status', 'active');

      final totalMembers = (totalMembersResponse as List).length;

      // 총 학습 세션 수
      final totalSessionsResponse = await _supabase
          .from('learning_sessions')
          .select('id')
          .eq('study_group_id', groupId);

      final totalSessions = (totalSessionsResponse as List).length;

      // 총 토론 세션 수 (스터디그룹 상태로 계산)
      final totalDiscussionsResponse = await _supabase
          .from('study_groups')
          .select('id')
          .eq('id', groupId)
          .eq('status', 'completed');

      final totalDiscussions = (totalDiscussionsResponse as List).length;

      final stats = {
        'totalMembers': totalMembers,
        'totalSessions': totalSessions,
        'totalDiscussions': totalDiscussions,
      };

      return Result.success(stats);
    } catch (e) {
      return Result.failure('스터디 그룹 통계를 조회하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 스크랩된 콘텐츠 기반으로 스터디 그룹용 토론 주제 3개 생성
  Future<Result<DiscussionTopics>> generateDiscussionTopicsFromScrap({
    required String userId,
    required String contentId,
    String? additionalContext,
  }) async {
    try {
      // 1. 콘텐츠 정보 가져오기
      final contentResult = await _contentService.getContentById(contentId);
      if (contentResult.isFailure) {
        return Result.failure(
          '콘텐츠를 찾을 수 없습니다: ${contentResult.errorMessageOrNull}',
          null,
        );
      }

      final content = contentResult.dataOrNull!;

      // 2. AI를 통해 스터디 그룹용 토론 주제 생성
      final topicsResult = await AiTopicModule.instance.aiTopicService
          .generateDiscussionTopics(
            contentText: content.content,
            contentType: content.contentType,
            additionalContext: '${additionalContext ?? ''} 스터디 그룹 토론용',
          );

      return topicsResult;
    } catch (e) {
      return Result.failure('토론 주제 생성 중 오류가 발생했습니다.', e);
    }
  }

  /// 콘텐츠 ID로 직접 스터디 그룹용 토론 주제 생성
  Future<Result<DiscussionTopics>> generateDiscussionTopics({
    required String contentId,
    String? additionalContext,
  }) async {
    try {
      // 1. 콘텐츠 정보 가져오기
      final contentResult = await _contentService.getContentById(contentId);
      if (contentResult.isFailure) {
        return Result.failure(
          '콘텐츠를 찾을 수 없습니다: ${contentResult.errorMessageOrNull}',
          null,
        );
      }

      final content = contentResult.dataOrNull!;

      // 2. AI를 통해 스터디 그룹용 토론 주제 생성
      final topicsResult = await AiTopicModule.instance.aiTopicService
          .generateDiscussionTopics(
            contentText: content.content,
            contentType: content.contentType,
            additionalContext: '${additionalContext ?? ''} 스터디 그룹 토론용',
          );

      return topicsResult;
    } catch (e) {
      return Result.failure('토론 주제 생성 중 오류가 발생했습니다.', e);
    }
  }

  /// 랜덤 콘텐츠 기반으로 스터디 그룹용 토론 주제 3개 생성
  Future<Result<DiscussionTopics>> generateDiscussionTopicsFromRandomContent({
    String? additionalContext,
  }) async {
    try {
      // 1. 랜덤 콘텐츠 하나 가져오기 (모든 콘텐츠에서)
      final contentsResult = await _contentService.getContents(
        page: 0,
        pageSize: 3, // 3개 중에서 랜덤 선택
      );

      if (contentsResult.isFailure ||
          contentsResult.dataOrNull == null ||
          contentsResult.dataOrNull!.isEmpty) {
        return Result.failure('사용 가능한 콘텐츠를 찾을 수 없습니다.', null);
      }

      final contents = contentsResult.dataOrNull!;

      // 2. 랜덤으로 하나 선택
      final randomIndex =
          DateTime.now().millisecondsSinceEpoch % contents.length;
      final selectedContent = contents[randomIndex];

      // 3. AI를 통해 스터디 그룹용 토론 주제 생성
      final topicsResult = await AiTopicModule.instance.aiTopicService
          .generateDiscussionTopics(
            contentText: selectedContent.content,
            contentType: selectedContent.contentType,
            additionalContext:
                '${additionalContext ?? ''} 스터디 그룹 토론용 (콘텐츠: ${selectedContent.title})',
          );

      return topicsResult;
    } catch (e) {
      return Result.failure('랜덤 콘텐츠 기반 토론 주제 생성 중 오류가 발생했습니다.', e);
    }
  }
}
