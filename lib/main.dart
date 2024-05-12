import 'package:flutter/material.dart';
import 'start_screen.dart';
import 'themes.dart'; // Импортируем файл с темами

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: AppTheme.primaryColor,
        fontFamily: AppTheme.regularDescriptionStyle.fontFamily,
      ),
      home: StartScreen(),
    );
  }
}
