import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';

class SmallCard extends StatelessWidget {
  final String title;
  final String contentType;
  final VoidCallback? onTap;
  final String? characterImagePath; // 캐릭터 이미지 경로

  const SmallCard({
    super.key,
    required this.title,
    required this.contentType,
    this.onTap,
    this.characterImagePath,
  });

  Color _getCardColor() {
    return AppColors.YBMlightPurple; // 항상 YBMlightPurple 사용
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80, // 높이를 더 넓게
        decoration: BoxDecoration(
          color: _getCardColor(),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            // 아래쪽은 둥글지 않게 해서 쌓인 느낌
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              // 제목 (두 줄)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'You can get 300 points!',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'You are in the top 23% now',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              // 캐릭터 이미지 (있으면 표시)
              if (characterImagePath != null) ...[
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(left: 0), // 왼쪽으로 이동
                  child: Image.asset(
                    characterImagePath!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // 이미지 로드 실패시 기본 아이콘 표시
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                // 캐릭터 이미지가 없으면 화살표 아이콘
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black.withOpacity(0.6),
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
