import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../content/pages/content_feed_page.dart'; // Added import for ContentFeedPage

// 상단 배경의 부드러운 곡선을 그리기 위한 CustomClipper
class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50); // 왼쪽 끝점
    // 화면 중앙 하단을 향해 부드러운 곡선 생성
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 50, // 곡선의 정점 (아래로 볼록)
      size.width,
      size.height - 50, // 오른쪽 끝점
    );
    path.lineTo(size.width, 0); // 오른쪽 상단
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class InterestSelectionPage extends StatefulWidget {
  const InterestSelectionPage({super.key});

  @override
  State<InterestSelectionPage> createState() => _InterestSelectionPageState();
}

class _InterestSelectionPageState extends State<InterestSelectionPage> {
  String? _selectedTest;
  final Set<String> _selectedInterests = {};
  final Set<String> _selectedCreators = {};

  // 점수 저장을 위한 Map 추가
  final Map<String, double> _scores = {
    'TOEIC Speaking': 100.0,
    'TOEIC Writing': 100.0,
    'TOEIC': 495.0,
  };

  // 시험별 만점
  final Map<String, double> _maxScores = {
    'TOEIC Speaking': 200.0,
    'TOEIC Writing': 200.0,
    'TOEIC': 990.0,
  };

  // 임시 데이터
  final List<String> _interestOptions = [
    'Technology',
    'Business',
    'Science',
    'Health',
    'Arts & Culture',
    'Politics',
    'Sports',
    'Travel',
  ];
  final List<Map<String, String>> _creatorOptions = [
    {'name': 'Elon Musk', 'icon': '🤖'},
    {'name': 'The Simpsons', 'icon': '🍩'},
    {'name': 'TechReview', 'icon': '💡'},
    {'name': 'BBC News', 'icon': '🌍'},
    {'name': 'The New York Times', 'icon': '📰'},
    {'name': 'National Geographic', 'icon': '🏞️'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50, // 전체 배경색
      body: Stack(
        children: [
          // 1. 상단 곡선 배경
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(height: 220, color: AppColors.YBMlightPurple),
          ),

          // 2. 메인 콘텐츠 (스크롤 가능)
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildScoreSection(),
                  const SizedBox(height: 24),
                  _buildInterestSection(),
                  const SizedBox(height: 24),
                  _buildCreatorSection(),
                  const SizedBox(height: 24),
                  _buildDoneButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 상단 헤더 (인사말, 캐릭터)
  Widget _buildHeader() {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          const Positioned(
            top: 40,
            left: 0,
            child: Text(
              'Hi, Waong!\nNice to meet you!',
              style: AppTextStyles.h2,
            ),
          ),
          Positioned(
            top: 30,
            right: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: -10,
            child: Image.asset(
              'assets/images/waong_character.png', // TODO: 캐릭터 이미지 경로 확인 필요
              width: 120,
              // 1. 뜬금없는 사람 아이콘 제거: 에러 발생 시 빈 컨테이너를 보여줌
              errorBuilder:
                  (context, error, stackTrace) =>
                      const SizedBox(width: 120, height: 120),
            ),
          ),
        ],
      ),
    );
  }

  // 2. 시험 성적 입력 칸 기능 구현
  Widget _buildScoreSection() {
    return _buildSectionCard(
      title:
          'Please tell us your current\nTOEIC / TOEIC Speaking / TOEIC Writing scores.',
      subtitle: '*You can skip this section if you don\'t have them.',
      child: Column(
        children: [
          _buildTestButton('TOEIC Speaking'),
          const SizedBox(height: 12),
          _buildTestButton('TOEIC Writing'),
          const SizedBox(height: 12),
          _buildTestButton('TOEIC'),
          const SizedBox(height: 12),
          // 선택된 시험이 있을 때만 점수 입력 슬라이더를 보여줌
          if (_selectedTest != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Your Score', style: AppTextStyles.labelLarge),
                      Text(
                        '${_scores[_selectedTest!]!.toInt()} / ${_maxScores[_selectedTest!]!.toInt()}',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _scores[_selectedTest!]!,
                    min: 0,
                    max: _maxScores[_selectedTest!]!,
                    divisions:
                        (_maxScores[_selectedTest!]! / 5).toInt(), // 5점 단위로 조절
                    label: _scores[_selectedTest!]!.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _scores[_selectedTest!] = value;
                      });
                    },
                    activeColor: AppColors.YBMdarkPurple,
                    inactiveColor: AppColors.YBMlightPurple,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // 관심 주제 선택 섹션
  Widget _buildInterestSection() {
    return _buildSectionCard(
      title:
          'Please tell us about the fields you\'d like to read and listen to in English!',
      subtitle:
          '*You can later change selected field.\n*You can select multiple fields.',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children:
            _interestOptions.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return ChoiceChip(
                label: Text(interest),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedInterests.add(interest);
                    } else {
                      _selectedInterests.remove(interest);
                    }
                  });
                },
                backgroundColor: AppColors.grey100,
                selectedColor: AppColors.YBMdarkPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.transparent),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              );
            }).toList(),
      ),
    );
  }

  // 3. 채널 추천 탭 아이콘 변경 (구글 기본 프로필 느낌)
  Widget _buildCreatorSection() {
    return _buildSectionCard(
      title: 'Choose channels you\'d like to follow!',
      subtitle: '*This helps us recommend better content for you.',
      child: Column(
        children:
            _creatorOptions.map((creator) {
              final isSelected = _selectedCreators.contains(creator['name']!);
              return CheckboxListTile(
                secondary: CircleAvatar(
                  backgroundColor: _getColorFor(creator['name']!),
                  child: Text(
                    creator['name']![0], // 첫 글자
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(creator['name']!, style: AppTextStyles.labelLarge),
                value: isSelected,
                onChanged: (selected) {
                  setState(() {
                    if (selected!) {
                      _selectedCreators.add(creator['name']!);
                    } else {
                      _selectedCreators.remove(creator['name']!);
                    }
                  });
                },
                activeColor: AppColors.YBMdarkPurple,
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
      ),
    );
  }

  // 섹션 카드 공통 위젯
  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  // 시험 선택 버튼
  Widget _buildTestButton(String testName) {
    final isSelected = _selectedTest == testName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTest = testName;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.YBMPurple : AppColors.YBMQuizPurple,
          borderRadius: BorderRadius.circular(24),
          border:
              isSelected
                  ? Border.all(color: AppColors.YBMdarkPurple, width: 2)
                  : null,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.school,
              size: 20,
              color: AppColors.textSecondary,
            ), // 임시 아이콘
            const SizedBox(width: 12),
            Text(
              testName,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 이름에 따라 고유한 색상을 반환하는 헬퍼 함수
  Color _getColorFor(String name) {
    // 간단한 해시 코드를 사용하여 색상 목록에서 색상 선택
    final colors = [
      AppColors.YBMBlue,
      AppColors.YBMPink,
      AppColors.YBMdarkPurple,
      Colors.orange,
      Colors.green,
      Colors.teal,
    ];
    final hash = name.hashCode;
    return colors[hash % colors.length];
  }

  // 완료 버튼
  Widget _buildDoneButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          // ContentFeedPage로 이동하도록 수정
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ContentFeedPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.YBMdarkPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Done',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
