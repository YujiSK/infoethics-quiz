import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:developer' as developer;
import 'dart:convert';
import 'dart:math';

void main() => runApp(const QuizApp());

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '情報倫理クイズ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TitlePage(),
    );
  }
}

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('情報技術者倫理クイズ①'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '情報技術者倫理',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  const Text('名古屋国際工科専門職大学', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 10),
                  const Text('砂川優治', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuizPage(),
                        ),
                      );
                    },
                    child: const Text('クイズを開始'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showQuizSelectionDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('クイズを選択'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _quizOptions.map((quiz) {
                return GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(quiz),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedQuiz = quiz;
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('閉じる'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class TitlePageWithSelection extends StatefulWidget {
  final String selectedQuiz;

  const TitlePageWithSelection({super.key, required this.selectedQuiz});

  @override
  State<TitlePageWithSelection> createState() => _TitlePageWithSelectionState();
}

class _TitlePageWithSelectionState extends State<TitlePageWithSelection> {
  @override
  void initState() => super.initState();

  @override
  Widget build(BuildContext context) {
    return const TitlePage();
  }
}

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

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    try {
      final loadedQuizData = await loadQuizData(widget.quizFile);
      quizData = await loadQuizData(); // Updated function call
      setState(() {
        quizData = loadedQuizData;
      });
      _shuffleOptions();
      _updateProgress();
    } catch (e) {
      developer.log('Error loading quiz data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _shuffleOptions() {
    if (quizData.isNotEmpty && currentQuestion < quizData.length) {
      shuffledIndices = List<int>.generate(
        quizData[currentQuestion]['options'].length,
        (i) => i,
      );
      shuffledIndices.shuffle(Random());
    }
  }

  void checkAnswer(int index) {
    if (answered) {
      return;
    }

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

    // スクロールを下へ
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
      if (currentQuestion < quizData.length) {
        _shuffleOptions();
      }
      _updateProgress();
    });
  }

  void _updateProgress() {
    if (quizData.isNotEmpty) {
      progress = (currentQuestion + 1) / quizData.length;
      if (answered && currentQuestion == quizData.length - 1) {
        progress = 1.0;
      }
    } else {
      progress = 0.0;
    }
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (quizData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.quizFile.contains('quiz_1.json')
                ? '情報技術者倫理クイズ1'
                : '情報技術者倫理クイズ2',
          ),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('クイズデータがありません。'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TitlePageWithSelection(
                        selectedQuiz: widget.quizFile,
                      ),
                    ),
                  );
                },
                child: const Text('タイトル画面に戻る'),
              ),
            ],
          ),
        ),
      );
    }

    if (currentQuestion >= quizData.length) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.quizFile.contains('quiz_1.json')
                ? '情報技術者倫理クイズ1'
                : '情報技術者倫理クイズ2',
          ),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'クイズ終了！正解数：$score / ${quizData.length}',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text(
                getFeedbackMessage(),
                style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const TitlePage()),
                  );
                },
                child: const Text('最初に戻る'),
              ),
            ],
          ),
        ),
      );
    }

    final question = quizData[currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: const Text('情報技術者倫理クイズ①'),
        automaticallyImplyLeading: false,
      ),
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
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
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

              return Card(
                child: ListTile(
                  title: Text(option),
                  tileColor: answered
                      ? isCorrect
                          ? Colors.green[100]
                          : isSelected
                              ? Colors.red[100]
                              : null
                      : null,
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
                      color: resultMessage!.startsWith('正解')
                          ? Colors.green
                          : Colors.red,
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
                      child: Text(
                        currentQuestion == quizData.length - 1 ? '終了' : '次の問題へ',
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

Future<List<Map<String, dynamic>>> loadQuizData() async {
  final jsonString = await rootBundle.loadString('assets/data/quiz.json');
  final List<dynamic> jsonData = json.decode(jsonString);
  return List<Map<String, dynamic>>.from(jsonData);
}
