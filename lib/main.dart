import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:link3_tech_task/main_screen.dart';
import 'to_do/task_group_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  AwesomeNotifications().initialize(
    null, // icon for your app notification
    [
      NotificationChannel(
        channelKey: 'scheduled_task_channel',
        channelName: 'Scheduled Task Notifications',
        channelDescription: 'Notification channel for scheduled tasks',
        defaultColor: Color(0xFF33CCCC),
        importance: NotificationImportance.High,
        channelShowBadge: true,
        locked: true,
      )
    ],
    debug: true,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Link3 Technologies Task',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MainScreen(),
    );
  }
}
