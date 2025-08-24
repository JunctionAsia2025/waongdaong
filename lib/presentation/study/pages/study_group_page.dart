import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';

class StudyGroupPage extends StatefulWidget {
  const StudyGroupPage({super.key});

  @override
  State<StudyGroupPage> createState() => _StudyGroupPageState();
}

class _StudyGroupPageState extends State<StudyGroupPage> {
  // 현실적인 스터디 그룹 데이터 (색상 포함)
  final List<Map<String, dynamic>> _recommendations = [
    {
      'title': 'Deep Dive into "The AI Revolution"',
      'source': 'TechReview',
      'participants': 3,
      'maxParticipants': 5,
      'color': AppColors.YBMQuizPurple, // 3. 불투명한 배경 적용
    },
    {
      'title': 'Analyzing Elon Musk\'s Latest Interview',
      'source': 'BBC News',
      'participants': 2,
      'maxParticipants': 4,
      'color': AppColors.YBMPurple,
    },
    {
      'title': 'The Economics of Climate Change',
      'source': 'The Economist',
      'participants': 4,
      'maxParticipants': 5,
      'color': AppColors.YBMQuizPurple,
    },
    {
      'title': 'Understanding a new paper on Quantum Computing',
      'source': 'Science Magazine',
      'participants': 1,
      'maxParticipants': 3,
      'color': AppColors.YBMPurple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Study Groups',
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 30),
              _buildSectionTitle('Upcoming Study'),
              const SizedBox(height: 16),
              _buildUpcomingStudyCard(),
              const SizedBox(height: 30),
              _buildSectionTitle('Study Group Recommendations'),
              const SizedBox(height: 16),
              _buildRecommendationStack(), // 겹쳐진 스택 레이아웃
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search...',
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey400),
        prefixIcon: const Icon(Icons.search, color: AppColors.grey400),
        filled: true,
        fillColor: AppColors.grey50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildUpcomingStudyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.YBMQuizPurple.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Discussing "Atomic Habits"', style: AppTextStyles.h4),
                SizedBox(height: 4),
                Text('Source: James Clear', style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_filled,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'PM 3:00',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '4',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 겹쳐진 카드 레이아웃 (겹침 정도 최종 조정)
  Widget _buildRecommendationStack() {
    const double cardHeight = 140.0;
    // 겹치는 정도를 110px에서 70px로 수정하여 보이는 부분을 70px로 늘림
    const double cardOverlap = 125.0;

    return SizedBox(
      // (전체 카드 수 - 1) * (카드높이 - 겹치는높이) + 마지막카드 전체높이 -> 잘못된 계산이었음
      // (전체 카드 수 - 1) * 보이는높이 + 마지막카드 전체높이 가 아님.
      // 각 카드는 top 에서부터 overlap 만큼 떨어져서 위치함.
      // 따라서 전체 높이는 (전체 카드 수 - 1) * overlap + cardHeight 가 맞음.
      // cardOverlap은 이전 카드와 겹치는 높이가 아니라, 카드가 시작되는 top 위치임.
      // 아, cardOverlap은 이전 카드의 top에서 얼마나 떨어져있는지.
      // cardHeight - cardOverlap 이 보이는 높이가 됨.
      // 140 - 110 = 30.
      // 140 - 70 = 70.
      // cardOverlap 값을 줄여야 덜 겹치게 됨.
      // 기존 110.0
      height: (_recommendations.length - 1) * cardOverlap + cardHeight,
      child: Stack(
        children: List.generate(_recommendations.length, (index) {
          final item = _recommendations[index];
          final topPosition = index * cardOverlap;
          return Positioned(
            top: topPosition,
            left: 0,
            right: 0,
            child: _buildRecommendationCard(item),
          );
        }),
      ),
    );
  }

  // 추천 스터디 카드 위젯
  Widget _buildRecommendationCard(Map<String, dynamic> studyData) {
    return Container(
      height: 140.0,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: studyData['color'] as Color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            studyData['title'] as String,
            style: AppTextStyles.h4,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 0),
          Text(
            studyData['source'] as String,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 10,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 1),
                  Text(
                    '${studyData['participants']}/${studyData['maxParticipants']}',
                    style: AppTextStyles.labelLarge,
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Join'),
                    SizedBox(width: 1),
                    Icon(Icons.arrow_forward, size: 10),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
