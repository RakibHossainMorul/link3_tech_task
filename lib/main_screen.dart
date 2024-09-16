import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link3_tech_task/sensor_tracking/sensor_tracking.dart';
import 'package:link3_tech_task/to_do/task_group_screen.dart';
import 'package:link3_tech_task/to_do/todo_splash_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      CupertinoPageRoute(builder: (_) => TodoSplashScreen()));
                },
                child: Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Color(0xFF36E0E0),
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Text(
                      "A To-Do List",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 13),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {

                  Navigator.push(context,
                      CupertinoPageRoute(builder: (_) => SensorTrackingScreen()));
                },
                child: Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Color(0xFF3F69FF),
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Text(
                      "Sensor Tracking",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
