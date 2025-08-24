import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../modules/content/models/content.dart';
import '../pages/content_detail_page.dart';

class ContentCard extends StatefulWidget {
  final Content content;

  const ContentCard({super.key, required this.content});

  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400), // 더 긴 애니메이션
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.3), // 더 크게 위로 이동
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap() async {
    // 카드가 위로 뽑히는 애니메이션
    await _animationController.forward();

    // 애니메이션이 끝나면 상세 페이지로 이동
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContentDetailPage(content: widget.content),
        ),
      ).then((_) {
        // 상세 페이지에서 돌아오면 애니메이션 리셋
        if (mounted) {
          _animationController.reset();
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  Color _getCardColor() {
    switch (widget.content.contentType) {
      case 'blog':
        return AppColors.YBMdarkPurple;
      case 'column':
        return AppColors.YBMBlue;
      case 'news':
        return AppColors.YBMPink;
      default:
        return AppColors.YBMdarkPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: GestureDetector(
              onTap: _onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: _getCardColor(), // contentType에 따른 배경색
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    // 아래쪽은 둥글지 않게 해서 쌓인 느낌
                  ),
                  boxShadow: [
                    // 기본 그림자
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                    // 애니메이션 시 더 깊은 그림자
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        _animationController.value * 0.2,
                      ),
                      blurRadius: 16 + (_animationController.value * 8),
                      offset: Offset(0, 4 + (_animationController.value * 8)),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title - 굵고 큰 글씨 (흰색)
                      Text(
                        widget.content.title,
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.w900, // 아주아주 굵은 글씨
                          color: Colors.black, // 검정색
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Created At - 작은 반투명 흰색
                      Text(
                        _formatDate(widget.content.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Content - 보통 크기 (반투명 흰색)
                      Text(
                        widget.content.content,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[600], // 회색
                          fontWeight: FontWeight.bold, // 굵은 글씨
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
