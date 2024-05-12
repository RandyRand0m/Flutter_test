import 'package:flutter/material.dart';

class AppTheme {
  // Цвета
  static const Color primaryColor = Color.fromRGBO(173, 181, 236, 1);
  static const Color primaryNotColor = Color.fromRGBO(225, 227, 241, 1);
  static const Color secondaryColor = Color.fromRGBO(226, 241, 225, 1);
  static const Color appBarColor = Color.fromRGBO(173, 181, 236, 1); // Цвет для AppBar
  static const Color textColor = Colors.black; // Цвет для текста
  
  // Шрифты
  static const TextStyle nameStyle = TextStyle(
    color: textColor,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontFamily: 'Roboto',
    
  );

  static const TextStyle regularTextStyle = TextStyle(
    color: textColor,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    fontFamily: 'Roboto',
  );

  static const TextStyle boldTextStyle = TextStyle(
    color: textColor,
    fontSize: 22,
    
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle regularDescriptionStyle = TextStyle(
    color: Color.fromRGBO(0, 0, 0, 0.6), // Устанавливаем цвет с прозрачностью 60%
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontFamily: 'Roboto',
  );
  static const TextStyle AddEditStyle = TextStyle(
    color: textColor, // Устанавливаем цвет с прозрачностью 60%
    fontSize: 22,
    fontWeight: FontWeight.normal,
    fontFamily: 'Roboto',
  );
}