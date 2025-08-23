import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 페이드 인 애니메이션 (0.8초)
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 스케일 애니메이션 (1.2초, 약간의 지연)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // 펄스 애니메이션 (2초 반복)
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 애니메이션 시작
    _startAnimations();
  }

  void _startAnimations() async {
    // 페이드 인 먼저 시작
    _fadeController.forward();

    // 0.3초 후 스케일 애니메이션 시작
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      _scaleController.forward();
    }

    // 1초 후 펄스 애니메이션 시작 (반복)
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _fadeAnimation,
              _scaleAnimation,
              _pulseAnimation,
            ]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.scale(
                  scale: _scaleAnimation.value * _pulseAnimation.value,
                  child: Image.asset(
                    'assets/images/title_LOGO.png',
                    width: 280,
                    height: 280,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 280,
                        height: 280,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.school,
                          size: 120,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
