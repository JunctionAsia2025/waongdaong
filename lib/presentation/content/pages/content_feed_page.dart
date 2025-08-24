import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../modules/content/models/content.dart';
import '../../../modules/content/services/content_service.dart';
import '../../../modules/supabase/supabase_module.dart';
import '../../shared/widgets/search_bar_widget.dart';
import '../widgets/content_card.dart';
import '../widgets/small_card.dart';
import '../../study/pages/study_list_page.dart';

class ContentFeedPage extends StatefulWidget {
  const ContentFeedPage({super.key});

  @override
  State<ContentFeedPage> createState() => _ContentFeedPageState();
}

class _ContentFeedPageState extends State<ContentFeedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late ContentService _contentService;
  List<Content> _contents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('🔥 initState 시작');

    _contentService = ContentService(SupabaseModule.instance.client);
    print('📦 ContentService 생성됨');

    print('📞 _loadContents 호출 시작');
    _loadContents();
    _checkContentTypes(); // content_type 확인 추가
    print('📞 _loadContents 호출 완료');

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 5, // 10 → 5로 줄여서 더 작은 움직임
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
  }

  Future<void> _loadContents() async {
    print('🚀 콘텐츠 로딩 시작...');

    try {
      print('📡 데이터베이스 호출 시작...');
      final result = await _contentService
          .getContents(pageSize: 15)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⏰ 타임아웃 발생!');
              throw TimeoutException(
                '콘텐츠 로딩 타임아웃',
                const Duration(seconds: 10),
              );
            },
          );
      print('📊 결과 받음: isSuccess=${result.isSuccess}');

      if (result.isSuccess && mounted) {
        final data = result.dataOrNull ?? [];
        print('✅ 성공! 데이터 개수: ${data.length}');
        setState(() {
          _contents = data;
          _isLoading = false;
        });
      } else {
        print('❌ 실패: ${result.errorMessageOrNull}');
        // 실패시 샘플 데이터로 폴백
        final sampleContents = [
          Content(
            id: '1',
            title: '샘플 콘텐츠 (DB 연결 실패)',
            content: '데이터베이스 연결에 실패하여 샘플 데이터를 표시합니다.',
            contentType: 'blog',
            difficultyLevel: 'beginner',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            updatedAt: DateTime.now().subtract(const Duration(days: 1)),
            categories: ['샘플'],
          ),
        ];
        setState(() {
          _contents = sampleContents;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('💥 예외 발생: $e');
      print('📍 스택 트레이스: $stackTrace');

      // 예외 발생시 샘플 데이터로 폴백
      final sampleContents = [
        Content(
          id: '1',
          title: '샘플 콘텐츠 (오류 발생)',
          content: '오류가 발생하여 샘플 데이터를 표시합니다: $e',
          contentType: 'news',
          difficultyLevel: 'beginner',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          categories: ['오류'],
        ),
      ];

      if (mounted) {
        setState(() {
          _contents = sampleContents;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkContentTypes() async {
    print('🔍 content_type 종류 확인 중...');
    try {
      final result = await _contentService.getContentTypeStats();
      if (result.isSuccess) {
        final stats = result.dataOrNull ?? {};
        print('📊 content_type 통계:');
        stats.forEach((type, count) {
          print('  - $type: $count개');
        });
      } else {
        print('❌ content_type 통계 실패: ${result.errorMessageOrNull}');
      }
    } catch (e) {
      print('💥 content_type 확인 오류: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 화면 바깥을 탭하면 키보드와 포커스 해제
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // 상단 반원 헤더 (화면 최상단에 붙임)
            Positioned(top: 0, left: 0, right: 0, child: _buildTopSemicircle()),

            // 둥근 네모박스 3개 (반원 하단에 겹쳐서 배치)
            Positioned(
              top: 150, // 30px 더 위로 올려서 확실히 겹치게
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRoundedBox(),
                  _buildRoundedBox(),
                  _buildRoundedBox(),
                ],
              ),
            ),

            // 검색바 (둥근 박스 아래)
            Positioned(
              top: 250, // 좀 더 아래로 이동
              left: 32, // 좌우 마진 늘림
              right: 32, // 좌우 마진 늘림
              child: SearchBarWidget(
                height: 40, // 기본 50에서 40으로 줄임
                onChanged: (value) {
                  // TODO: 검색 로직 구현
                  print('검색어: $value');
                },
                onSubmitted: (value) {
                  // TODO: 검색 실행 로직 구현
                  print('검색 실행: $value');
                },
              ),
            ),

            // 메인 콘텐츠 영역
            Positioned.fill(
              top: 290, // 검색바 영역 줄여서 작은 카드가 잘리지 않게
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 콘텐츠 리스트 (작은 카드와 겹치게)
                    Expanded(
                      child: Stack(
                        children: [
                          // 작은 카드 (콘텐츠 카드 뒤에 숨겨지게)
                          Positioned(
                            top: 5, // 둥근 모서리가 보이도록 아래로
                            left: 0,
                            right: 0,
                            child: SmallCard(
                              title: 'You can get 300 points!',
                              contentType: 'blog',
                              characterImagePath:
                                  'assets/images/main_waong.png', // 캐릭터 이미지 경로
                              onTap: () {
                                print('작은 카드 터치');
                              },
                            ),
                          ),
                          // 메인 콘텐츠 카드들 (작은 카드 위에 겹쳐서 스크롤시 가림)
                          Transform.translate(
                            offset: const Offset(0, 10), // 살짝 아래로
                            child:
                                _isLoading
                                    ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(50.0),
                                        child: CircularProgressIndicator(
                                          color: AppColors.YBMPurple,
                                        ),
                                      ),
                                    )
                                    : _contents.isEmpty
                                    ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(50.0),
                                        child: Text(
                                          '콘텐츠가 없습니다',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    )
                                    : ListView.builder(
                                      itemCount: _contents.length,
                                      itemBuilder: (context, index) {
                                        return Transform.translate(
                                          offset: Offset(
                                            0,
                                            index == 0 ? 0 : -16.0 * index,
                                          ),
                                          child: ContentCard(
                                            content: _contents[index],
                                          ),
                                        );
                                      },
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 우측 하단 동그라미 버튼
            Positioned(
              bottom: 24,
              right: 24,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudyListPage(),
                    ),
                  );
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black, // 검정색 배경
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.group, color: Colors.white, size: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSemicircle() {
    return Container(
      height: 250, // 확실히 크게 늘림
      width: double.infinity,
      child: Stack(
        children: [
          // 반원 배경 (화면 최상단부터)
          CustomPaint(painter: SemicirclePainter(), size: Size.infinite),
          // 텍스트 내용 (SafeArea 적용)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 2.0,
                bottom: 35.0, // 더 아래로 이동
              ),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _animation.value),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.end, // center → end로 변경해서 아래로 이동
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hi, 사용자!',
                          style: AppTextStyles.h2.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w900, // 아주 굵은 볼드
                          ),
                        ),
                        // SizedBox 제거해서 공간 절약
                        Text(
                          'Nice to meet you!',
                          style: AppTextStyles.h2.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w900, // 위쪽 텍스트와 동일하게
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedBox() {
    return Container(
      width: 110,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.YBMlightPurple,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 프로필 사진과 이름
            Row(
              children: [
                // 프로필 사진
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.grey300,
                  child: Icon(Icons.person, size: 16, color: AppColors.grey600),
                ),
                const SizedBox(width: 6),
                // 이름
                Expanded(
                  child: Text(
                    '사용자 이름',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // 2줄 텍스트
            Text(
              '여기에 간단한 설명 텍스트가 들어갑니다. 길어지면 말줄임표로 표시됩니다.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}

class SemicirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.YBMPurple
          ..style = PaintingStyle.fill;

    // 반원 그리기 (화면 맨 위에 바짝 붙이고 더 위쪽을 잘라냄)
    final rect = Rect.fromLTWH(
      -size.width * 0.5, // 좌측으로 확장
      -size.height * 1.3, // 더 위쪽으로 올려서 위쪽을 잘라내고 화면에 더 붙임
      size.width * 2, // 너비를 2배로 확장
      size.height * 2, // 높이를 2배로 확장
    );

    canvas.drawArc(
      rect,
      0, // 시작 각도 (0도 = 오른쪽)
      3.14159, // 끝 각도 (π = 180도, 반원)
      false, // useCenter = false (부채꼴이 아닌 호)
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
