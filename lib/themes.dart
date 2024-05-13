import 'package:flutter/material.dart';

class AppTheme {
  // Цвета
  static const Color primaryColor = Color.fromRGBO(173, 181, 236, 1); // Основной цвет
  static const Color primaryNotColor = Color.fromRGBO(225, 227, 241, 1); // для неотправленного увведомления
  static const Color secondaryColor = Color.fromRGBO(226, 241, 225, 1); // для отправленного уведомления
  static const Color appBarColor = Color.fromRGBO(173, 181, 236, 1); // для AppBar
  static const Color textColor = Colors.black; // для текста
  
  // Шрифты
  static const TextStyle nameStyle = TextStyle( // Название в списке
    color: textColor,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontFamily: 'Roboto',
    
  );

  static const TextStyle regularTextStyle = TextStyle( // Обычный текст
    color: textColor,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    fontFamily: 'Roboto',
  );

  static const TextStyle boldTextStyle = TextStyle( // Название приложения
    color: textColor,
    fontSize: 22, 
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle regularDescriptionStyle = TextStyle( // Текст описания
    color: Color.fromRGBO(0, 0, 0, 0.6), 
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontFamily: 'Roboto',
  );

  static const TextStyle AddEditStyle = TextStyle( // Текст label
    color: textColor,
    fontSize: 22,
    fontWeight: FontWeight.normal,
    fontFamily: 'Roboto',
  );
}