import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:link3_tech_task/to_do/task_group_screen.dart';
import 'package:link3_tech_task/to_do/task_list_screen.dart';

import '../services/db_helper.dart';

class TaskDeleteScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  final int groupID;

  const TaskDeleteScreen(
      {super.key, required this.task, required this.groupID});

  @override
  State<TaskDeleteScreen> createState() => _TaskDeleteScreenState();
}

class _TaskDeleteScreenState extends State<TaskDeleteScreen> {
  bool tapRemainder = false;
  bool tapDateTime = false;
  bool tapNotes = false;
  bool tapDelete = false;
  late TextEditingController titleController = TextEditingController();
  late TextEditingController descriptionController = TextEditingController();
  DateTime? _selectedDateTime;

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Make background transparent
      builder: (BuildContext context) {
        return Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors
                .transparent, // Transparent background for outer container
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: double.infinity, // Full width for both buttons
                child: Container(
                  height: 60, // Set the precise height
                  margin: EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // White background for Confirm Delete button
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      await _deleteTask(widget.task['id']);

                      // setState(() {
                      //   tapDelete = false;
                      // });
                      // Navigator.pop(context);
                      print("delete task");
                    },
                    child: Text(
                      'Confirm Delete',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10), // Transparent gap
              SizedBox(
                width: double.infinity, // Full width for both buttons
                child: Container(
                  height: 60,
                  // Set the precise height to match the Confirm Delete button
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white, // White background for Cancel button
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        tapDelete = false;
                      });
                      Navigator.pop(context); // Close bottom sheet on cancel
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    titleController =
        TextEditingController(text: widget.task["title"].toString());
    descriptionController =
        TextEditingController(text: widget.task["description"].toString());
    _selectedDateTime = DateTime.parse(widget.task["due_date"]); // Ini
    super.initState();
  }

  Future<void> _pickDateTime() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(widget.task["due_date"]),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(DateTime.parse(widget.task["due_date"])),
      );

      if (selectedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _fetchTasks() async {
    final data = await DBHelper.instance.getTasks(widget.groupID);
  }

  Future<void> _deleteTask(int id) async {
    await DBHelper.instance.deleteTask(id);
    _fetchTasks();
    if (context.mounted) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => TaskGroupScreen()));
    }
  }

  void _scheduleNotification(String taskTitle, DateTime dateTime) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'scheduled_task_channel',
        title: 'Task Reminder',
        body: 'It\'s time for your task: $taskTitle',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: dateTime.year,
        month: dateTime.month,
        day: dateTime.day,
        hour: dateTime.hour,
        minute: dateTime.minute,
        second: 0,
        millisecond: 0,
        repeats: false,
      ),
    );
  }
  Future<void> updateSpecificTask(int taskId) async {
    Map<String, dynamic> updatedTask = {
      'title': titleController.text,
      'description': descriptionController.text,
      'due_date': _selectedDateTime.toString(),
    };

    int result = await DBHelper.instance.updateTask(taskId, updatedTask);

    if (result > 0) {
      print('Task updated successfully!');
    } else {
      print('Failed to update task.');
    }
  }
  @override
  Widget build(BuildContext context) {
    print(
      _selectedDateTime.toString(),
    );
    return Scaffold(
      backgroundColor: Color(0xFFE5E5E5),
      appBar: AppBar(
        backgroundColor: Color(0xFFE5E5E5),
        title: Text(
          widget.task["title"].toString(),
        ),
        actions: [
          tapNotes == true || tapDateTime || tapRemainder
              ? GestureDetector(
                  onTap: () async {
                    print("update task");
                    updateSpecificTask(widget.task["id"]);
                    _scheduleNotification(
                        titleController.text, _selectedDateTime!);

                    await _fetchTasks();
                    if(context.mounted){
                      Navigator.push(context, CupertinoPageRoute(builder: (_)=>TaskListScreen(groupId: widget.groupID)));


                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Container(
                      height: 25,
                      width: 70,
                      decoration: BoxDecoration(
                          color: Color(0xFF33CCCC),
                          borderRadius: BorderRadius.circular(50)),
                      child: Center(
                        child: Text(
                          "Update",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  ))
              : Container()
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        tapRemainder = true;
                      });
                    },
                    child: AnimatedContainer(
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color:
                              tapRemainder ? Color(0xFF33CCCC) : Colors.white,
                        ),
                        duration: Duration(milliseconds: 300),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Row(children: [
                            Icon(
                              Icons.notifications,
                              size: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Remainder",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  color: Color(0xFF585858)),
                            )
                          ]),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        _pickDateTime();
                        // setState(() {
                        //   tapDateTime=true;
                        // });
                      },
                      child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Column(
                              children: [
                                Row(children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Date & Time",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: Color(0xFF585858)),
                                  )
                                ]),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: Row(children: [
                                    Icon(
                                      CupertinoIcons.arrow_turn_down_right,
                                      size: 12,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "Due " +
                                          DateFormat('EEE, dd MMM').format(
                                              DateTime.parse(_selectedDateTime
                                                  .toString())),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 10,
                                          color: Color(0xFF33CCCC)),
                                    )
                                  ]),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        tapNotes = true;
                      });
                    },
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: tapNotes ? 150 : 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(children: [
                                Icon(
                                  Icons.sticky_note_2_sharp,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "Update Tasks",
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12,
                                      color: Color(0xFF585858)),
                                )
                              ]),
                              tapNotes
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(right: 10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextFormField(
                                            controller: titleController,
                                            decoration: InputDecoration(
                                                label: Text("Task Title"),
                                                hintText: "Title"),
                                          ),
                                          TextFormField(
                                            controller: descriptionController,
                                            decoration: InputDecoration(
                                                label: Text("Task Description"),
                                                hintText: "Description"),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        )),
                  ),
                ],
              ),
              tapDelete
                  ? Container()
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          tapDelete = true;
                        });
                        _showBottomSheet(context);
                      },
                      child: AnimatedContainer(
                          height: 40,
                          duration: Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Row(children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                                size: 20,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "Delete",
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFF585858)),
                              )
                            ]),
                          )),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
