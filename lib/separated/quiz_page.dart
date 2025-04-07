// quiz_page.dart
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:developer' as developer;
import 'dart:convert';
import 'dart:math';

import 'quiz_functions.dart'; // 作成した関数ファイルをインポート
import 'quiz_title_page.dart'; // HomePage をインポート

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  QuizPageState createState() => QuizPageState();
}

class QuizPageState extends State<QuizPage> {
  int currentQuestion = 0;
  int score = 0;
  bool answered = false;
  int? selectedIndex;
  List<int> shuffledIndices = [];
  String? resultMessage;
  final ScrollController _scrollController = ScrollController();
  double progress = 0.0;
  List<Map<String, dynamic>> quizData = [];
  bool _isLoading = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadQuizData();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadQuizData() async {
    try {
      quizData = await loadQuizData();
      _shuffleOptions();
      _updateProgress();
    } catch (e) {
      developer.log('Error loading quiz data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _shuffleOptions() {
    shuffledIndices = List<int>.generate(quizData[currentQuestion]['options'].length, (i) => i);
    shuffledIndices.shuffle(Random());
  }

  void checkAnswer(int index) {
    if (answered) return;

    setState(() {
      selectedIndex = index;
      answered = true;
      final originalIndex = shuffledIndices[index];
      if (originalIndex == quizData[currentQuestion]['answer_index']) {
        score++;
        resultMessage = '正解：${quizData[currentQuestion]['explanation']}';
      } else {
        resultMessage = '不正解：${quizData[currentQuestion]['explanation']}';
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void nextQuestion() {
    setState(() {
      currentQuestion++;
      answered = false;
      selectedIndex = null;
      resultMessage = null;
      if (currentQuestion < quizData.length) _shuffleOptions();
      _updateProgress();
      _focusNode.requestFocus();
    });
  }

  void _updateProgress() {
    progress = (currentQuestion + 1) / quizData.length;
    if (answered && currentQuestion == quizData.length - 1) progress = 1.0;
  }

  String getFeedbackMessage() {
    double percentage = score / quizData.length;

    if (percentage == 1.0) {
      return '完璧です！素晴らしい理解力！';
    } else if (percentage >= 0.8) {
      return 'とても良いです！あと少しで満点！';
    } else if (percentage >= 0.6) {
      return '合格ラインです。もう一度復習するとさらに安心！';
    } else {
      return 'もう一度内容をしっかり復習しましょう。';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (currentQuestion >= quizData.length) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('情報技術者倫理クイズ①'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('クイズ終了！正解数：$score / ${quizData.length}', style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 10),
              Text(getFeedbackMessage(), style: const TextStyle(fontSize: 18, color: Colors.blueGrey)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
                },
                child: const Text('最初に戻る'),
              ),
            ],
          ),
        ),
      );
    }

    final question = quizData[currentQuestion];

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        final result = handleAnswerKeyPress(
          _focusNode,
          event,
          answered,
          quizData,
          currentQuestion,
          shuffledIndices,
          checkAnswer,
        );
        if (result == KeyEventResult.handled) return result;
        return handleNextQuestionKeyPress(event, answered, nextQuestion);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('情報技術者倫理クイズ①'), automaticallyImplyLeading: false),
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: progress, end: progress),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return OpenContainer(
                    transitionDuration: const Duration(milliseconds: 500),
                    openBuilder: (context, VoidCallback closeContainer) {
                      return Container(
                        padding: const EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      );
                    },
                    closedBuilder: (context, VoidCallback openContainer) {
                      return InkWell(
                        onTap: openContainer,
                        child: LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 10),
              Text(question['question'], style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 16),
              ...List.generate(question['options'].length, (index) {
                final originalIndex = shuffledIndices[index];
                final option = question['options'][originalIndex];
                final isCorrect = originalIndex == question['answer_index'];
                final isSelected = index == selectedIndex;
                final optionNumber = index + 1;

                return Card(
                  child: ListTile(
                    title: Row(
                      children: [
                        Text('($optionNumber) '),
                        Expanded(child: Text(option)),
                      ],
                    ),
                    tileColor: answered ? isCorrect ? Colors.green[100] : isSelected ? Colors.red[100] : null : null,
                    onTap: () => checkAnswer(index),
                  ),
                );
              }),
              if (answered)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      resultMessage != null ? '$resultMessage\n' : '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: resultMessage!.startsWith('正解') ? Colors.green : Colors.red,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        onPressed: nextQuestion,
                        child: Text(currentQuestion == quizData.length - 1 ? '次へ' : '次の問題へ'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> loadQuizData() async {
  final jsonString = await rootBundle.loadString('assets/data/quiz.json');
  final List<dynamic> jsonData = json.decode(jsonString);
  return List<Map<String, dynamic>>.from(jsonData);
}
