import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../modules/content/models/content.dart';
import '../../../modules/quiz/models/quiz.dart';
import '../../../modules/quiz/quiz_module.dart';
import 'quiz_result_page.dart';

class ContentSessionPage extends StatefulWidget {
  final Content content;

  const ContentSessionPage({super.key, required this.content});

  @override
  State<ContentSessionPage> createState() => _ContentSessionPageState();
}

class _ContentSessionPageState extends State<ContentSessionPage> {
  List<Quiz> _quizzes = [];
  int _currentQuizIndex = 0;
  bool _isLoading = true;
  String? _error;
  final Map<int, String> _userAnswers = {};
  final PageController _pageController = PageController();
  final TextEditingController _answerController = TextEditingController();

  // 타입별 퀴즈 그룹
  List<Quiz> _vocabularyQuizzes = [];
  List<Quiz> _translationQuizzes = [];
  List<Quiz> _summaryQuizzes = [];

  // 현재 진행 중인 타입과 해당 타입 내 인덱스
  QuizType _currentType = QuizType.vocabulary;
  int _currentTypeIndex = 0;

  // 타입별 완료 상태
  final Map<QuizType, bool> _typeCompleted = {
    QuizType.vocabulary: false,
    QuizType.translation: false,
    QuizType.summary: false,
  };

  @override
  void initState() {
    super.initState();
    _generateQuizzes();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _generateQuizzes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🔥 퀴즈 생성 시작');
      print('📝 Content ID: ${widget.content.id}');
      print('📝 Content length: ${widget.content.content.length}');
      print('📝 Difficulty: ${widget.content.difficultyLevel}');

      final quizService = QuizModule.instance.quizService;
      print('🔧 QuizService 획득 완료');

      final result = await quizService.generateQuizzesForContent(
        contentId: widget.content.id,
        contentText: widget.content.content,
        difficultyLevel: widget.content.difficultyLevel,
        vocabularyCount: 3, // 단어 퀴즈 3개
        summaryCount: 1, // 요약 퀴즈 1개 (본문 전체 요약)
        translationCount: 3, // 번역 퀴즈 3개
      );

      print('📊 퀴즈 생성 결과: ${result.isSuccess}');

      if (result.isSuccess) {
        final allQuizzes = result.dataOrNull ?? [];
        print('✅ 생성된 퀴즈 개수: ${allQuizzes.length}');

        if (allQuizzes.isEmpty) {
          print('⚠️ AI가 퀴즈를 생성하지 못했습니다. 샘플 퀴즈를 사용합니다.');
          final sampleQuizzes = _createSampleQuizzes();
          _groupQuizzesByType(sampleQuizzes);

          setState(() {
            _quizzes = sampleQuizzes;
            _isLoading = false;
          });
          return;
        }

        for (int i = 0; i < allQuizzes.length; i++) {
          print(
            '📋 퀴즈 $i: ${allQuizzes[i].quizType.value} - ${allQuizzes[i].question}',
          );
        }

        _groupQuizzesByType(allQuizzes);
        print('📊 그룹화 결과:');
        print('  - 단어: ${_vocabularyQuizzes.length}개');
        print('  - 번역: ${_translationQuizzes.length}개');
        print('  - 요약: ${_summaryQuizzes.length}개');

        setState(() {
          _quizzes = allQuizzes;
          _isLoading = false;
        });
      } else {
        print('❌ 퀴즈 생성 실패: ${result.errorMessageOrNull}');
        print('🔄 임시 샘플 퀴즈로 대체합니다');

        // 임시 샘플 퀴즈 생성
        final sampleQuizzes = _createSampleQuizzes();
        _groupQuizzesByType(sampleQuizzes);

        setState(() {
          _quizzes = sampleQuizzes;
          _isLoading = false;
          _error = null; // 에러 대신 샘플 퀴즈 사용
        });
      }
    } catch (e) {
      print('💥 퀴즈 생성 예외 발생: $e');
      print('🔄 임시 샘플 퀴즈로 대체합니다');

      // 임시 샘플 퀴즈 생성
      final sampleQuizzes = _createSampleQuizzes();
      _groupQuizzesByType(sampleQuizzes);

      setState(() {
        _quizzes = sampleQuizzes;
        _isLoading = false;
        _error = null; // 에러 대신 샘플 퀴즈 사용
      });
    }
  }

  List<Quiz> _createSampleQuizzes() {
    const uuid = Uuid();
    return [
      // 단어 퀴즈 3개
      Quiz(
        id: uuid.v4(),
        contentId: widget.content.id,
        quizType: QuizType.vocabulary,
        question:
            'The company faced significant _______ during the economic downturn.',
        correctAnswer: 'challenges',
        options: ['challenges', 'opportunities', 'celebrations', 'vacations'],
        difficultyLevel: widget.content.difficultyLevel,
        points: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Quiz(
        id: uuid.v4(),
        contentId: widget.content.id,
        quizType: QuizType.vocabulary,
        question: 'The new technology will _______ improve our efficiency.',
        correctAnswer: 'significantly',
        options: ['significantly', 'barely', 'never', 'sometimes'],
        difficultyLevel: widget.content.difficultyLevel,
        points: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Quiz(
        id: uuid.v4(),
        contentId: widget.content.id,
        quizType: QuizType.vocabulary,
        question: 'The team needs to _______ their strategy for next quarter.',
        correctAnswer: 'develop',
        options: ['develop', 'destroy', 'ignore', 'forget'],
        difficultyLevel: widget.content.difficultyLevel,
        points: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // 번역 퀴즈 3개
      Quiz(
        id: uuid.v4(),
        contentId: widget.content.id,
        quizType: QuizType.translation,
        question: 'Translate the following sentence into Korean:',
        excerpt: 'The global economy is experiencing unprecedented changes.',
        correctAnswer: '세계 경제는 전례 없는 변화를 겪고 있습니다.',
        difficultyLevel: widget.content.difficultyLevel,
        points: 15,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Quiz(
        id: uuid.v4(),
        contentId: widget.content.id,
        quizType: QuizType.translation,
        question: 'Translate the following sentence into Korean:',
        excerpt: 'Technology plays a crucial role in modern business.',
        correctAnswer: '기술은 현대 비즈니스에서 중요한 역할을 합니다.',
        difficultyLevel: widget.content.difficultyLevel,
        points: 15,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Quiz(
        id: uuid.v4(),
        contentId: widget.content.id,
        quizType: QuizType.translation,
        question: 'Translate the following sentence into Korean:',
        excerpt: 'Companies must adapt to changing market conditions.',
        correctAnswer: '회사들은 변화하는 시장 상황에 적응해야 합니다.',
        difficultyLevel: widget.content.difficultyLevel,
        points: 15,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // 요약 퀴즈 1개 (본문 전체 요약)
      Quiz(
        id: uuid.v4(),
        contentId: widget.content.id,
        quizType: QuizType.summary,
        question:
            'Summarize the entire article in 3-4 sentences in English. Your summary should capture the main points and key information.',
        excerpt: widget.content.content, // 본문 전체
        correctAnswer:
            'This article discusses the impact of digital transformation on modern business operations. Companies that embrace new technologies and adapt to changing market conditions gain significant competitive advantages. The text emphasizes how remote work and artificial intelligence are reshaping industries while highlighting the importance of strategic adaptation for business success.',
        difficultyLevel: widget.content.difficultyLevel,
        points: 30, // 더 어려우므로 점수 증가
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  void _groupQuizzesByType(List<Quiz> allQuizzes) {
    _vocabularyQuizzes =
        allQuizzes.where((q) => q.quizType == QuizType.vocabulary).toList();
    _translationQuizzes =
        allQuizzes.where((q) => q.quizType == QuizType.translation).toList();
    _summaryQuizzes =
        allQuizzes.where((q) => q.quizType == QuizType.summary).toList();

    // 첫 번째 타입부터 시작
    _currentType = QuizType.vocabulary;
    _currentTypeIndex = 0;
    _answerController.text = _userAnswers[_getCurrentGlobalIndex()] ?? '';
  }

  List<Quiz> _getCurrentTypeQuizzes() {
    switch (_currentType) {
      case QuizType.vocabulary:
        return _vocabularyQuizzes;
      case QuizType.translation:
        return _translationQuizzes;
      case QuizType.summary:
        return _summaryQuizzes;
    }
  }

  int _getCurrentGlobalIndex() {
    int globalIndex = 0;
    switch (_currentType) {
      case QuizType.vocabulary:
        globalIndex = _currentTypeIndex;
        break;
      case QuizType.translation:
        globalIndex = _vocabularyQuizzes.length + _currentTypeIndex;
        break;
      case QuizType.summary:
        globalIndex =
            _vocabularyQuizzes.length +
            _translationQuizzes.length +
            _currentTypeIndex;
        break;
    }
    return globalIndex;
  }

  void _nextQuiz() {
    final currentTypeQuizzes = _getCurrentTypeQuizzes();
    if (_currentTypeIndex < currentTypeQuizzes.length - 1) {
      setState(() {
        _currentTypeIndex++;
        _answerController.text = _userAnswers[_getCurrentGlobalIndex()] ?? '';
      });
    }
  }

  void _saveAnswer() {
    _userAnswers[_getCurrentGlobalIndex()] = _answerController.text;
    setState(() {}); // 버튼 상태 업데이트
  }

  void _submitCurrentAnswer() {
    if (_answerController.text.trim().isEmpty) return;

    _saveAnswer();

    final currentTypeQuizzes = _getCurrentTypeQuizzes();
    if (_currentTypeIndex < currentTypeQuizzes.length - 1) {
      // 같은 타입 내 다음 문제로 이동
      _nextQuiz();
    } else {
      // 현재 타입 완료
      _completeCurrentType();
    }
  }

  void _completeCurrentType() {
    // 현재 타입의 모든 문제가 답변되었는지 확인
    final currentTypeQuizzes = _getCurrentTypeQuizzes();
    bool allAnswered = true;

    for (int i = 0; i < currentTypeQuizzes.length; i++) {
      final globalIndex = _getGlobalIndexForType(_currentType, i);
      if (_userAnswers[globalIndex]?.trim().isEmpty ?? true) {
        allAnswered = false;
        break;
      }
    }

    if (!allAnswered) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 문제를 풀어주세요!')));
      return;
    }

    // 현재 타입 완료 표시
    _typeCompleted[_currentType] = true;

    // 다음 타입으로 이동 또는 전체 완료
    _moveToNextType();
  }

  int _getGlobalIndexForType(QuizType type, int typeIndex) {
    switch (type) {
      case QuizType.vocabulary:
        return typeIndex;
      case QuizType.translation:
        return _vocabularyQuizzes.length + typeIndex;
      case QuizType.summary:
        return _vocabularyQuizzes.length +
            _translationQuizzes.length +
            typeIndex;
    }
  }

  void _moveToNextType() {
    switch (_currentType) {
      case QuizType.vocabulary:
        if (_translationQuizzes.isNotEmpty) {
          setState(() {
            _currentType = QuizType.translation;
            _currentTypeIndex = 0;
            _answerController.text =
                _userAnswers[_getCurrentGlobalIndex()] ?? '';
          });
        } else {
          _moveToSummaryOrComplete();
        }
        break;
      case QuizType.translation:
        _moveToSummaryOrComplete();
        break;
      case QuizType.summary:
        _completeAllQuizzes();
        break;
    }
  }

  void _moveToSummaryOrComplete() {
    if (_summaryQuizzes.isNotEmpty) {
      setState(() {
        _currentType = QuizType.summary;
        _currentTypeIndex = 0;
        _answerController.text = _userAnswers[_getCurrentGlobalIndex()] ?? '';
      });
    } else {
      _completeAllQuizzes();
    }
  }

  void _completeAllQuizzes() {
    // AI 채점 및 결과 계산
    final results = _calculateResults();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => QuizResultPage(
              quizzes: _quizzes,
              userAnswers: _userAnswers,
              results: results,
              content: widget.content,
            ),
      ),
    );
  }

  void _completeQuiz() {
    // AI 채점 및 결과 계산 (임시 구현)
    final results = _calculateResults();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => QuizResultPage(
              quizzes: _quizzes,
              userAnswers: _userAnswers,
              results: results,
              content: widget.content,
            ),
      ),
    );
  }

  Map<String, dynamic> _calculateResults() {
    int correctAnswers = 0;
    int totalScore = 0;
    int maxPossibleScore = 0;

    for (int i = 0; i < _quizzes.length; i++) {
      final quiz = _quizzes[i];
      final userAnswer = _userAnswers[i] ?? '';
      maxPossibleScore += quiz.points;

      // 임시 채점 로직 (실제로는 AI 채점 사용)
      final isCorrect = _evaluateAnswer(quiz, userAnswer);
      if (isCorrect) {
        correctAnswers++;
        totalScore += quiz.points;
      }
    }

    final accuracyRate =
        _quizzes.isEmpty ? 0.0 : (correctAnswers / _quizzes.length) * 100;

    return {
      'totalQuizzes': _quizzes.length,
      'correctAnswers': correctAnswers,
      'accuracyRate': accuracyRate,
      'totalScore': totalScore,
      'maxPossibleScore': maxPossibleScore,
    };
  }

  bool _evaluateAnswer(Quiz quiz, String userAnswer) {
    if (userAnswer.trim().isEmpty) return false;

    if (quiz.quizType == QuizType.vocabulary) {
      return userAnswer.trim().toLowerCase() ==
          quiz.correctAnswer.trim().toLowerCase();
    }

    // 번역/요약의 경우 임시로 길이 기반 평가 (실제로는 AI 평가 사용)
    return userAnswer.trim().length >= 10;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
            'AI Quiz Session',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('AI가 퀴즈를 생성하고 있습니다...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
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
            'AI Quiz Session',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _generateQuizzes,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (_quizzes.isEmpty) {
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
            'AI Quiz Session',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(child: Text('생성된 퀴즈가 없습니다.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'AI Quiz Session',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator - 현재 타입의 진행 상황만 표시
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                // 타입 표시
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTypeIndicator(QuizType.vocabulary),
                    const SizedBox(width: 8),
                    _buildTypeIndicator(QuizType.translation),
                    const SizedBox(width: 8),
                    _buildTypeIndicator(QuizType.summary),
                  ],
                ),
                const SizedBox(height: 12),
                // 현재 타입 내 진행 상황
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_getCurrentTypeQuizzes().length, (
                    index,
                  ) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            index == _currentTypeIndex
                                ? AppColors.YBMBlue
                                : AppColors.grey300,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Quiz Content - 현재 타입의 퀴즈만 표시
          Expanded(child: _buildCurrentQuizCard()),
        ],
      ),
    );
  }

  Widget _buildTypeIndicator(QuizType type) {
    String typeName = '';
    bool isCompleted = _typeCompleted[type] ?? false;
    bool isCurrent = _currentType == type;

    switch (type) {
      case QuizType.vocabulary:
        typeName = 'Word';
        break;
      case QuizType.translation:
        typeName = 'Translation';
        break;
      case QuizType.summary:
        typeName = 'Summary';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isCompleted
                ? Colors.green
                : isCurrent
                ? AppColors.YBMBlue
                : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        typeName,
        style: AppTextStyles.bodySmall.copyWith(
          color: isCompleted || isCurrent ? Colors.white : Colors.grey.shade600,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCurrentQuizCard() {
    final currentTypeQuizzes = _getCurrentTypeQuizzes();
    if (currentTypeQuizzes.isEmpty) {
      return const Center(child: Text('퀴즈가 없습니다.'));
    }

    final currentQuiz = currentTypeQuizzes[_currentTypeIndex];
    return _buildQuizCard(currentQuiz, _currentTypeIndex);
  }

  Widget _buildQuizCard(Quiz quiz, int index) {
    String stepTitle = '';
    Color cardColor = AppColors.YBMlightPurple;

    switch (quiz.quizType) {
      case QuizType.vocabulary:
        stepTitle = 'Word Quiz';
        cardColor = AppColors.YBMlightPurple;
        break;
      case QuizType.translation:
        stepTitle = 'Translation';
        cardColor = AppColors.YBMlightPurple;
        break;
      case QuizType.summary:
        stepTitle = 'Summary';
        cardColor = AppColors.YBMlightPurple;
        break;
    }

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Main Quiz Card
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Step ${index + 1}: $stepTitle',
                              style: AppTextStyles.h4.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${index + 1} / ${_getCurrentTypeQuizzes().length}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${quiz.points} points',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Question Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (quiz.excerpt != null) ...[
                            Text(
                              quiz.excerpt!,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (quiz.isVocabulary) ...[
                            // Word Quiz with blank
                            RichText(
                              text: TextSpan(
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                                children: _buildWordQuizText(quiz.question),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Hint icon
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: Colors.black54,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Hint',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            // Translation/Summary Quiz
                            Text(
                              quiz.question,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Answer Field
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _answerController,
                      onChanged: (value) {
                        _saveAnswer();
                        setState(() {}); // 버튼 상태 실시간 업데이트
                      },
                      onSubmitted: (value) => _submitCurrentAnswer(),
                      maxLines: quiz.isVocabulary ? 1 : 3,
                      textInputAction:
                          quiz.isVocabulary
                              ? TextInputAction.done
                              : TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText:
                            quiz.isVocabulary
                                ? 'Enter the word...'
                                : quiz.isSummary
                                ? 'Write your summary here...'
                                : 'Write your translation here...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                      ),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Submit Button
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          _answerController.text.trim().isEmpty
                              ? null
                              : _submitCurrentAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _answerController.text.trim().isEmpty
                                ? Colors.grey.shade300
                                : AppColors.YBMBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation:
                            _answerController.text.trim().isEmpty ? 0 : 2,
                      ),
                      child: Text(
                        _getSubmitButtonText(),
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              _answerController.text.trim().isEmpty
                                  ? Colors.grey.shade600
                                  : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildWordQuizText(String question) {
    // 빈칸을 찾아서 밑줄로 표시
    final parts = question.split('_______');
    final spans = <TextSpan>[];

    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i]));
      if (i < parts.length - 1) {
        spans.add(
          TextSpan(
            text: '_______',
            style: TextStyle(
              decoration: TextDecoration.underline,
              decorationThickness: 2,
              decorationColor: Colors.black54,
            ),
          ),
        );
      }
    }

    return spans;
  }

  String _getSubmitButtonText() {
    final currentTypeQuizzes = _getCurrentTypeQuizzes();
    if (_currentTypeIndex < currentTypeQuizzes.length - 1) {
      return '다음 문제';
    } else {
      // 현재 타입의 마지막 문제
      if (_currentType == QuizType.vocabulary &&
          (_translationQuizzes.isNotEmpty || _summaryQuizzes.isNotEmpty)) {
        return '완료';
      } else if (_currentType == QuizType.translation &&
          _summaryQuizzes.isNotEmpty) {
        return '완료';
      } else {
        return '제출';
      }
    }
  }

  bool _isCurrentTypeCompleted() {
    final currentTypeQuizzes = _getCurrentTypeQuizzes();
    for (int i = 0; i < currentTypeQuizzes.length; i++) {
      final globalIndex = _getGlobalIndexForType(_currentType, i);
      if (_userAnswers[globalIndex]?.trim().isEmpty ?? true) {
        return false;
      }
    }
    return true;
  }
}
