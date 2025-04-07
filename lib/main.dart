import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(QuizApp());

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '情報倫理クイズ',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TitlePage(),
    );
  }
}

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('情報技術者倫理クイズ①'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '情報技術者倫理',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  Text('名古屋国際工科専門職大学', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 10),
                  Text('砂川優治', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QuizPage()),
                      );
                    },
                    child: Text('クイズを開始'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestion = 0;
  int score = 0;
  bool answered = false;
  int? selectedIndex;
  List<int> shuffledIndices = [];
  String? resultMessage;
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> quizData = [
    {
      "question": "実践的な社会問題の解決を扱う倫理学は，どれか？",
      "options": ["形式倫理学", "応用倫理学", "メタ倫理学", "規範倫理学"],
      "answer_index": 1,
      "explanation": "応用倫理学は、生命倫理・環境倫理・情報倫理など、現代社会の実践的課題に倫理的視点から取り組む分野です。",
    },
    {
      "question": "組織が脆弱性を修正するまで、脆弱性を開示しないという慣行は，どれか？",
      "options": ["完全な開示", "十分な開示", "説明責任の開示", "責任ある開示"],
      "answer_index": 3,
      "explanation": "責任ある開示は、組織に修正の機会を与えるための倫理的アプローチです。",
    },
    {
      "question": "情報倫理の対象ではないのは，どれか？",
      "options": ["情報社会と法の差異", "価値観の対立", "地球環境の持続性", "情報についての行動指針"],
      "answer_index": 2,
      "explanation": "地球環境の持続性は環境倫理の領域です。",
    },
    {
      "question": "職業倫理の説明は，どれか？",
      "options": [
        "職業を営む上で必要なコンプライアンス",
        "職業を営む上で必要な善悪の判断基準",
        "職業を営む上で必要な顧客価値",
        "職業を営む上で必要な利益",
      ],
      "answer_index": 1,
      "explanation": "職業倫理は、専門職が社会的責任を果たすために必要な善悪の判断基準を意味します。",
    },
    {
      "question": "倫理綱領の記述でないのは，どれか？",
      "options": [
        "専門家が直面する具体的な事態への対処事例",
        "社会に対する専門家の義務",
        "専門家集団が果たすべき社会的責任",
        "専門職の行動指針",
      ],
      "answer_index": 0,
      "explanation": "倫理綱領は一般的な行動原則を示したものであり、具体的な事例の列挙は通常含まれません。",
    },
  ];

  @override
  void initState() {
    super.initState();
    _shuffleOptions();
  }

  void _shuffleOptions() {
    shuffledIndices = List<int>.generate(
      quizData[currentQuestion]['options'].length,
      (i) => i,
    );
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
    });
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
    if (currentQuestion >= quizData.length) {
      return Scaffold(
        appBar: AppBar(
          title: Text('情報技術者倫理クイズ①'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'クイズ終了！正解数：$score / ${quizData.length}',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 10),
              Text(
                getFeedbackMessage(),
                style: TextStyle(fontSize: 18, color: Colors.blueGrey),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TitlePage()),
                  );
                },
                child: Text('最初に戻る'),
              ),
            ],
          ),
        ),
      );
    }

    final question = quizData[currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: Text('情報技術者倫理クイズ'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(question['question'], style: TextStyle(fontSize: 20)),
            SizedBox(height: 16),
            ...List.generate(question['options'].length, (index) {
              final originalIndex = shuffledIndices[index];
              final option = question['options'][originalIndex];
              final isCorrect =
                  originalIndex == question['answer_index']; // 元のindexで判定
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
                  SizedBox(height: 16),
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
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      onPressed: nextQuestion,
                      child: Text('次の問題へ'),
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