import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import 'interest_selection_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 테스트용 로그인 핸들러 추가
  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text;
      final password = _passwordController.text;

      // 테스트용 로그인 자격 증명
      if (email == 'test@test.com' && password == 'password') {
        // 로그인 성공 시 다음 페이지로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const InterestSelectionPage(),
          ),
        );
      } else {
        // 로그인 실패 시 간단한 스낵바 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('아이디 또는 비밀번호가 일치하지 않습니다.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // 페이지 전체에 일관된 수평 패딩을 적용하여 폭을 조정
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 25),
              Image.asset('assets/images/title_LOGO.png', width: 170),
              const SizedBox(height: 20),
              _buildThoughtBubbles(),
              const SizedBox(height: 20),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThoughtBubbles() {
    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: const BoxDecoration(
            color: AppColors.YBMPurple,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(15),
          child: const Center(
            child: Text(
              "Start your journey of\n'English for life,'\nnot 'English for exams'",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.YBMPurple,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // 배경이 되는 거대한 원의 상단 부분
        Container(
          margin: const EdgeInsets.only(top: 30),
          height: 220,
          decoration: const BoxDecoration(
            color: AppColors.YBMPurple,
            // 매우 큰 반지름을 주어 곡선을 완만하게 만듦
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(250),
              topRight: Radius.circular(250),
            ),
          ),
        ),
        // 로그인 폼
        _buildSignInForm(),
      ],
    );
  }

  Widget _buildSignInForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sign In',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _buildInputDecoration('email or user id'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이메일 또는 사용자 ID를 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: _buildInputDecoration('password').copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          // 로그인 버튼 추가
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.YBMdarkPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.textTertiary),
      filled: true,
      // fillColor를 연한 회색으로 수정
      fillColor: AppColors.grey50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
