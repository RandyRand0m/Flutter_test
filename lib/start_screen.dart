// ignore_for_file: prefer_final_fields, no_leading_underscores_for_local_identifiers
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'notification_item.dart';
import 'themes.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  List<NotificationItem> _notifications = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  List<String> tags = ['Акция', 'Мероприятие', 'Напоминание','Персональная рекомендация'];
  String? selectedTag; 
  
  late tz.Location _local;
  late DateTime selectedDateTime = DateTime.now();
  
  late TextEditingController _dateController = TextEditingController();
  late TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _local = tz.UTC;
    _loadNotifications();
  }

  //Загрузка
  Future<void> _loadNotifications() async { 
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _notifications = (prefs.getStringList('notifications') ?? []).map((item) {
          List<String> parts = item.split('|'); // Разделение данных уведомлений
          return NotificationItem(
            title: parts[0],
            description: parts[1], 
            dateTime: DateFormat("yyyy-MM-dd HH:mm").parse(parts[2]),
            tag: parts[3],
          );
        }).toList();
      });
    }

  // Сохранение
  Future<void> _saveNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); 
    List<String> notificationsData = _notifications.map((item) {
      return '${item.title}|${item.description}|${DateFormat("yyyy-MM-dd HH:mm").format(item.dateTime)}|${item.tag}'; 
    }).toList();
    await prefs.setStringList('notifications', notificationsData);
  }

  @override
  Widget build(BuildContext context) {
    _loadNotifications();
    return Scaffold(
      appBar: AppBar(              
        title: const Text(
          'УВЕДОМЛЕНИЯ',
          style: AppTheme.boldTextStyle,
        ),
      ),
      body: ListView.builder(  
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          return Container(  //Список уведомлений
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            decoration: BoxDecoration(                
              color: _getNotificationColor(_notifications[index]),
              border: Border.all(
                color: _getNotificationColor(_notifications[index]),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile( //Элемент списка
              title: Text(_notifications[index].title,),
              titleTextStyle: AppTheme.nameStyle,
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_notifications[index].description, maxLines: 1, overflow: TextOverflow.ellipsis,style:AppTheme.regularDescriptionStyle), // Описание уведомления
                ],
              ),
              trailing: IconButton( //Кнопка удаления
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _notifications.removeAt(index); // Удаление уведомления
                  });
                  _saveNotifications();
                },
              ),
              onTap: () {
                _showEditNotificationScreen(context, index); // Редактирование при нажатии на уведомление
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:AppTheme.primaryColor,
        onPressed: () {
          _showAddNotificationScreen(context); // Открытие экрана добавления
        },
        child: const Icon(Icons.add,),
      ),
    );
  }
  
    Duration _timeUntilNotification(NotificationItem notification) { //Таймер до оправки
      
      DateTime now = DateTime.now();
      Duration difference = notification.dateTime.difference(now);
      return difference;
    }

    Color _getNotificationColor(NotificationItem notification) { //Смена цвета по таймеру
      
      Duration difference = _timeUntilNotification(notification);
      if (difference.inSeconds > 0) {
        return AppTheme.primaryNotColor;
      }  else {
        return AppTheme.secondaryColor; 
      }
    }

    Future<void> _scheduleNotification(NotificationItem? notification) async { //Планирование уведомления

      var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'your_channel_id11',
        'Clown',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        icon: '@mipmap/ic_launcher',
      );
      var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );
      
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notification.hashCode,
          notification?.title,
          notification?.description,
          tz.TZDateTime.from(notification!.dateTime, _local),
          platformChannelSpecifics,
          // ignore: deprecated_member_use
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (e) {
          //print('Error scheduling notification: $e');
      }
    }

    void _showAddNotificationScreen(BuildContext context) { //Экран добавления
      
      DateTime _selectedNotificationTime = DateTime.now(); 
      String title = '';
      String description = '';
      DateTime selectedDateTime = DateTime.now();  
      
      Container(
        width: 100,
        height: 2,
        color: Colors.black,
      );
      
      showModalBottomSheet(         
        isScrollControlled: true,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (BuildContext context) {
          _dateController.text = DateFormat("yyyy-MM-dd").format(selectedDateTime);
          _timeController.text = DateFormat("HH:mm").format(selectedDateTime);
          return Container(
            height: MediaQuery.of(context).size.height * 0.93,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 70,
                  height: 4,
                  color: Colors.black,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Создать уведомление',
                  style: AppTheme.AddEditStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                TextField( //Название                  
                  onChanged: (value) {
                    title = value;
                  },
                  decoration: InputDecoration(                    
                    labelText: 'Название',
                    labelStyle: AppTheme.regularDescriptionStyle,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),                    
                  ),
                  
                  maxLines: 1,
                  style: AppTheme.regularTextStyle,
                ),
                const SizedBox(height: 10),
                TextField( //Описание
                  
                  onChanged: (value) {
                    description = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Описание',
                    labelStyle: AppTheme.regularDescriptionStyle,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  style: AppTheme.regularTextStyle,
                  maxLines: 1,
                ),
                const SizedBox(height: 10),
                TextFormField( //Дата
                  readOnly: true,
                  controller: _dateController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    labelText: 'Дата',
                    labelStyle: AppTheme.regularDescriptionStyle,
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  style: AppTheme.regularTextStyle,
                  
                  onTap: () async {
                    
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDateTime,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedDateTime) {
                      setState(() {
                        selectedDateTime = picked;
                        _dateController.text = DateFormat("yyyy-MM-dd").format(selectedDateTime);
                        _selectedNotificationTime = DateTime(
                        _selectedNotificationTime.year,
                        _selectedNotificationTime.month,
                        _selectedNotificationTime.day,
                        picked.hour,
                        picked.minute,
                      );
                      });
                    }
                  
                  },
                ),
                const SizedBox(height: 10), //Время
                TextFormField(
                  readOnly: true,
                  controller: _timeController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    labelText: 'Время',
                    suffixIcon: const Icon(Icons.access_time),
                  ),
                  style: AppTheme.regularTextStyle,
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                    );
                    if (picked != null && picked != TimeOfDay.fromDateTime(selectedDateTime)) {
                      setState(() {
                        selectedDateTime = DateTime(
                          selectedDateTime.year,
                          selectedDateTime.month,
                          selectedDateTime.day,
                          picked.hour,
                          picked.minute,
                        );
                        _timeController.text = DateFormat("HH:mm").format(selectedDateTime);
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                
                Wrap( // Теги
                  alignment: WrapAlignment.start, 
                  spacing: 5.0,
                  children: List.generate(
                    tags.length,
                    (index) => ChoiceChip(
                      label: Text(tags[index],
                        style: AppTheme.regularTextStyle,
                      ),
                      selected: selectedTag == tags[index], 
                      onSelected: (selected) {
                        setState(() {
                          selectedTag = selected ? tags[index] : null; 
                        });
                      },
                      backgroundColor: selectedTag == tags[index] ? AppTheme.primaryColor : null,
                      selectedColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(color: selectedTag == tags[index] ? Colors.white : Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row( //Кнопки отмена\создание
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(AppTheme.primaryColor), // Устанавливаем красный цвет фона
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Отменить',style: AppTheme.regularTextStyle),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(AppTheme.primaryColor), // Устанавливаем красный цвет фона
                      ),
                      onPressed: () {
                        setState(() {
                          _notifications.add(NotificationItem(
                            title: title,
                            description: description,
                            dateTime: selectedDateTime,
                            tag: selectedTag,
                          ));
                        });
                        _saveNotifications();
                        _scheduleNotification(NotificationItem(
                          title: title,
                          description: description,
                          dateTime: selectedDateTime,
                          tag: selectedTag,
                        ));
                        Navigator.pop(context);
                      },
                      child: const Text('Добавить',style: AppTheme.regularTextStyle,),                          
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
   
    void _showEditNotificationScreen(BuildContext context, int index) { //Окно редактирования
      
      String title = _notifications[index].title;
      String description = _notifications[index].description;
      DateTime selectedDateTime = _notifications[index].dateTime;
      String? selectedTag = _notifications[index].tag; 
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (BuildContext context) {
          _dateController.text = DateFormat("yyyy-MM-dd").format(selectedDateTime);
          _timeController.text = DateFormat("HH:mm").format(selectedDateTime);
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.93,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    //mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 70,
                        height: 4,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 10),
                      const Text('Редактировать', style:AppTheme.AddEditStyle),                      
                      const SizedBox(height: 20),
                      TextField( //Название
                        controller: TextEditingController(text: title),
                        onChanged: (value) {
                          title = value; 
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          labelText: 'Название',
                          labelStyle: AppTheme.regularDescriptionStyle
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField( //Описание
                        controller: TextEditingController(text: description),
                        onChanged: (value) {
                          description = value; 
                        },
                        decoration: InputDecoration(
                          labelText: 'Описание',
                          labelStyle: AppTheme.regularDescriptionStyle,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField( //Дата
                        readOnly: true,
                        controller: _dateController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          labelText: 'Дата',
                          labelStyle: AppTheme.regularDescriptionStyle,
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDateTime,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != selectedDateTime) {
                            setState(() {
                              selectedDateTime = picked;
                              _dateController.text = DateFormat("yyyy-MM-dd").format(selectedDateTime);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField( //Время
                        readOnly: true,
                        controller: _timeController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          labelText: 'Время',
                          labelStyle: AppTheme.regularDescriptionStyle,
                          suffixIcon: const Icon(Icons.access_time),
                        ),
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                          );
                          if (picked != null && picked != TimeOfDay.fromDateTime(selectedDateTime)) {
                            setState(() {
                              selectedDateTime = DateTime(
                                selectedDateTime.year,
                                selectedDateTime.month,
                                selectedDateTime.day,
                                picked.hour,
                                picked.minute,
                              );
                              _timeController.text = DateFormat("HH:mm").format(selectedDateTime);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      Wrap( //Теги
                        spacing: 5.0,
                        children: List.generate(
                          tags.length,
                          (index) => ChoiceChip(
                            label: Text(tags[index],
                              style: AppTheme.regularTextStyle),
                            selected: selectedTag == tags[index],
                            onSelected: (selected) {
                              setState(() {
                                selectedTag = selected ? tags[index] : null; 
                              });
                            },
                            backgroundColor: selectedTag == tags[index] ? AppTheme.primaryColor : null,
                            selectedColor: AppTheme.primaryColor,
                            labelStyle: TextStyle(color: selectedTag == tags[index] ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10), 
                      Row( //Кнопки отмена\создание
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(AppTheme.primaryColor),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Отменить',style: AppTheme.regularTextStyle),
                              
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(AppTheme.primaryColor),
                            ),
                            onPressed: () {
                              setState(() {
                                _notifications[index].title = title;
                                _notifications[index].description = description;
                                _notifications[index].dateTime = selectedDateTime;
                              });
                              _saveNotifications();
                              _scheduleNotification(_notifications[index]);
                              Navigator.pop(context);
                            },
                            child: const Text('Сохранить',style: AppTheme.regularTextStyle),
                          ),
                        ],
                      ),
                      
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }
  } 
