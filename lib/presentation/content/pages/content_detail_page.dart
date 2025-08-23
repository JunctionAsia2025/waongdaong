import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../modules/content/models/content.dart';
import '../../../modules/ai_trans/ai_trans_module.dart';
import '../../../modules/ai_trans/controllers/ai_trans_controller.dart';
import '../widgets/translation_bottom_sheet.dart';
import 'content_session_page.dart';

class ContentDetailPage extends StatefulWidget {
  final Content content;

  const ContentDetailPage({super.key, required this.content});

  @override
  State<ContentDetailPage> createState() => _ContentDetailPageState();
}

class _ContentDetailPageState extends State<ContentDetailPage>
    with SingleTickerProviderStateMixin {
  late AiTransController _transController;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _transController = AiTransModule.instance.aiTransController;
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  void _showAnimatedAlert(String message) {
    // 기존 오버레이가 있으면 제거
    _overlayEntry?.remove();

    late AnimationController animationController;
    animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // 아래에서 시작
      end: const Offset(0, 0), // 중앙으로
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutBack),
    );

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
    );

    _overlayEntry = OverlayEntry(
      builder:
          (context) => AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: Center(
                    child: SlideTransition(
                      position: slideAnimation,
                      child: FadeTransition(
                        opacity: fadeAnimation,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          child: Text(
                            message,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
    );

    // 오버레이 표시
    Overlay.of(context).insert(_overlayEntry!);

    // 애니메이션 시작
    animationController.forward();

    // 1.2초 후 자동으로 제거
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && _overlayEntry != null) {
        animationController.reverse().then((_) {
          _overlayEntry?.remove();
          _overlayEntry = null;
          animationController.dispose();
        });
      }
    });
  }

  /// 선택된 텍스트를 한 문장으로 제한
  String _limitToSentence(String selectedText) {
    // 마침표를 찾아서 그 이전까지만 반환
    final periodIndex = selectedText.indexOf('.');
    if (periodIndex != -1) {
      return selectedText.substring(0, periodIndex + 1).trim();
    }
    return selectedText.trim();
  }

  /// 선택된 텍스트가 한 문장을 초과하는지 확인
  bool _isMultipleSentences(String selectedText) {
    final periodIndex = selectedText.indexOf('.');
    if (periodIndex != -1 && periodIndex < selectedText.length - 1) {
      // 마침표 이후에 더 많은 텍스트가 있는 경우
      final afterPeriod = selectedText.substring(periodIndex + 1).trim();
      return afterPeriod.isNotEmpty;
    }
    return false;
  }

  /// 번역 실행
  void _translateSelectedText(String selectedText) {
    // 한 문장 초과 여부 확인
    if (_isMultipleSentences(selectedText)) {
      // 커스텀 애니메이션 알림 표시
      _showAnimatedAlert('번역 기능은 최대 한 문장까지만 가능합니다!');
      return; // 번역 실행하지 않고 종료
    }

    final limitedText = _limitToSentence(selectedText);
    print('🔄 선택된 텍스트: "$selectedText"');
    print('🔄 제한된 텍스트: "$limitedText"');

    if (limitedText.isNotEmpty && mounted) {
      // 번역 실행
      _transController.translateText(text: limitedText);

      // 하단 시트 표시
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: true, // 바깥 터치로 닫기 가능
        enableDrag: true, // 드래그로 닫기 가능
        builder:
            (context) => TranslationBottomSheet(
              controller: _transController,
              originalText: limitedText,
            ),
      ).then((_) {
        // 하단 시트가 닫혔을 때의 처리 (필요시)
        print('📱 번역 하단 시트가 닫혔습니다');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'View Original',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.content.title,
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Created At
            Text(
              '${widget.content.createdAt.year}.${widget.content.createdAt.month.toString().padLeft(2, '0')}.${widget.content.createdAt.day.toString().padLeft(2, '0')}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // Content - 드래그 선택 가능
            SelectableText(
              widget.content.content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
              ),
              onSelectionChanged: (selection, cause) {
                // 텍스트 선택 변경 감지 (컨텍스트 메뉴에서 처리)
              },
              contextMenuBuilder: (context, editableTextState) {
                // 커스텀 컨텍스트 메뉴 - 복사만 남기기
                final selection = editableTextState.textEditingValue.selection;
                if (selection.baseOffset != selection.extentOffset) {
                  final selectedText = widget.content.content.substring(
                    selection.baseOffset,
                    selection.extentOffset,
                  );

                  return AdaptiveTextSelectionToolbar(
                    anchors: editableTextState.contextMenuAnchors,
                    children: [
                      // 복사 버튼
                      TextSelectionToolbarTextButton(
                        padding: const EdgeInsets.all(8.0),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: selectedText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('복사되었습니다'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: const Text('복사'),
                      ),
                      // 번역 버튼
                      TextSelectionToolbarTextButton(
                        padding: const EdgeInsets.all(8.0),
                        onPressed: () {
                          // 번역 실행
                          _translateSelectedText(selectedText);
                        },
                        child: const Text('번역'),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      // 하단 Go Study Session 버튼
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            ContentSessionPage(content: widget.content),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28), // 둥근 모서리
                ),
                elevation: 0,
              ),
              child: Text(
                'Go Study Session',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
