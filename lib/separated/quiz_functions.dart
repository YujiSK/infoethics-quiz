// quiz_functions.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// キー入力で回答をチェックする関数
KeyEventResult handleAnswerKeyPress(
  FocusNode focusNode,
  KeyEvent event, // Updated from RawKeyEvent to KeyEvent
  bool answered,
  List<Map<String, dynamic>> quizData,
  int currentQuestion,
  List<int> shuffledIndices,
  void Function(int) checkAnswerCallback,
) {
  if (event is KeyDownEvent) { // Updated from RawKeyDownEvent to KeyDownEvent
    if (!answered) {
      if (event.logicalKey == LogicalKeyboardKey.digit1 ||
          event.logicalKey == LogicalKeyboardKey.numpad1) {
        if (quizData[currentQuestion]['options'].length > 0) {
          checkAnswerCallback(0);
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.digit2 ||
          event.logicalKey == LogicalKeyboardKey.numpad2) {
        if (quizData[currentQuestion]['options'].length > 1) {
          checkAnswerCallback(1);
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.digit3 ||
          event.logicalKey == LogicalKeyboardKey.numpad3) {
        if (quizData[currentQuestion]['options'].length > 2) {
          checkAnswerCallback(2);
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.digit4 ||
          event.logicalKey == LogicalKeyboardKey.numpad4) {
        if (quizData[currentQuestion]['options'].length > 3) {
          checkAnswerCallback(3);
          return KeyEventResult.handled;
        }
      }
    }
  }
  return KeyEventResult.ignored;
}

// キー入力で次の質問に進む関数
KeyEventResult handleNextQuestionKeyPress(
  KeyEvent event, // Updated from RawKeyEvent to KeyEvent
  bool answered,
  void Function() nextQuestionCallback,
) {
  if (event is KeyDownEvent && answered && // Updated from RawKeyDownEvent to KeyDownEvent
      (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space)) {
    nextQuestionCallback();
    return KeyEventResult.handled;
  }
  return KeyEventResult.ignored;
}