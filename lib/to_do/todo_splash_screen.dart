


import 'package:flutter/material.dart';
import 'package:link3_tech_task/to_do/task_group_screen.dart';


class TodoSplashScreen extends StatefulWidget {
  const TodoSplashScreen({super.key});

  @override
  State<TodoSplashScreen> createState() => _TodoSplashScreenState();
}

class _TodoSplashScreenState extends State<TodoSplashScreen> {



  @override
  void initState() {
    super.initState();

    // Delay for 3 seconds and then navigate to the HomeScreen
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TaskGroupScreen()),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           Image.asset("assets/tasks 1.png"),
            SizedBox(height: 20),
            Text(
              'Daily To-Do App',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
