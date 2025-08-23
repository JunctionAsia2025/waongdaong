import 'package:flutter/material.dart';
import 'modules/supabase/supabase_module.dart';
import 'modules/ai_script/ai_script_module.dart';
import 'modules/ai_script/controllers/ai_script_controller.dart';
import 'modules/app_module_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase 모듈 초기화
  await SupabaseModule.instance.initialize();

  // AI 스크립트 모듈 초기화 (실제 Gemini API 사용)
  AiScriptModule.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaongDaong',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // 간단한 사용자 이름 기반 인증 상태 확인
    final authService = SupabaseModule.instance.auth;

    if (authService.isAuthenticated) {
      // 로그인된 상태
      return const MyHomePage(title: 'WaongDaong Home');
    } else {
      // 로그인되지 않은 상태
      return const LoginPage();
    }
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (_usernameController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('사용자 이름을 입력해주세요')));
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await SupabaseModule.instance.auth.signInWithUsername(
        _usernameController.text.trim(),
      );

      if (success && mounted) {
        // 로그인 성공 시 페이지 새로고침
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MyHomePage(title: 'WaongDaong Home'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('로그인 실패: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: '사용자 이름',
                border: OutlineInputBorder(),
                hintText: '중복되지 않는 사용자 이름을 입력하세요',
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('로그인'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final AiScriptController _aiController = AiScriptController();
  String _testResult = '';
  bool _isModulesInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeModules();
  }

  Future<void> _initializeModules() async {
    try {
      setState(() {
        _testResult = 'AppModuleManager 초기화 중...';
      });

      // AppModuleManager를 통해 모든 모듈 초기화
      await AppModuleManager.instance.initialize(
        SupabaseModule.instance.client,
      );

      setState(() {
        _testResult = '모든 모듈 초기화 완료!';
        _isModulesInitialized = true;
      });
    } catch (e) {
      setState(() {
        _testResult = '모듈 초기화 오류: $e';
      });
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  // 세 가지 스타일 스크립트 생성 테스트
  Future<void> _testThreeStyleScripts() async {
    setState(() {
      _testResult = '테스트 중...';
    });

    try {
      final result = await _aiController.generateThreeStyleScripts(
        koreanInput: '안녕하세요, 만나서 반갑습니다',
        basicPrompt: '첫 만남에서의 인사',
      );

      if (result != null) {
        setState(() {
          _testResult = '''
테스트 성공! 

격식있는: ${result.formal}

편한: ${result.casual}

재치있는: ${result.witty}
''';
        });
      } else {
        setState(() {
          _testResult = '테스트 실패: ${_aiController.errorMessage}';
        });
      }
    } catch (e) {
      setState(() {
        _testResult = '테스트 오류: $e';
      });
    }
  }

  // 랜덤 콘텐츠 기반 토론 주제 생성 테스트
  Future<void> _testDiscussionTopics() async {
    if (!_isModulesInitialized) {
      setState(() {
        _testResult = '모듈 초기화 중입니다. 잠시 후 다시 시도해주세요.';
      });
      return;
    }

    setState(() {
      _testResult = '랜덤 콘텐츠 기반 토론 주제 생성 중...';
    });

    try {
      // 랜덤 콘텐츠를 선택해서 토론 주제 생성
      final result = await AppModuleManager.instance.studyModule.studyService
          .generateDiscussionTopicsFromRandomContent(
            additionalContext: '영어 학습 스터디 그룹용',
          );

      if (result.isSuccess && result.dataOrNull != null) {
        final topics = result.dataOrNull!;
        setState(() {
          _testResult = '''
랜덤 콘텐츠 기반 토론 주제 생성 성공! 

주제 1: ${topics.topic1}

주제 2: ${topics.topic2}

주제 3: ${topics.topic3}
''';
        });
      } else {
        setState(() {
          _testResult = '토론 주제 생성 실패: ${result.errorMessageOrNull}';
        });
      }
    } catch (e) {
      setState(() {
        _testResult = '토론 주제 생성 오류: $e';
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await SupabaseModule.instance.auth.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('로그아웃 실패: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = SupabaseModule.instance.auth.currentUsername;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (username != null) ...[
              Text(
                '환영합니다, $username님!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
            const Text('버튼을 누른 횟수:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed:
                  _aiController.isLoading ? null : _testThreeStyleScripts,
              child:
                  _aiController.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('AI 세 가지 스타일 테스트'),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _isModulesInitialized ? _testDiscussionTopics : null,
              child: Text(
                _isModulesInitialized
                    ? '랜덤 콘텐츠 기반 토론 주제 생성 테스트'
                    : '모듈 초기화 중...',
              ),
            ),
            const SizedBox(height: 16),
            if (_testResult.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_testResult, style: const TextStyle(fontSize: 14)),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
