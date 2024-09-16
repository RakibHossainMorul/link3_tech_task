import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:link3_tech_task/to_do/task_list_delete_screen.dart';
import '../services/db_helper.dart';

class TaskListScreen extends StatefulWidget {
  final int groupId;

  TaskListScreen({required this.groupId});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Map<String, dynamic>> tasks = [];
  bool bottomSheetTap = false;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final data = await DBHelper.instance.getTasks(widget.groupId);
    setState(() {
      tasks = data;
    });
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Color(0xFFF8F8F8),
        title: Text('Tasks List'),
        actions: [
          bottomSheetTap
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      if (titleController.text.isNotEmpty &&
                          descriptionController.text.isNotEmpty &&
                          selectedDate != null) {
                        DBHelper.instance.createTask({
                          'group_id': widget.groupId,
                          'title': titleController.text,
                          'description': descriptionController.text,
                          'due_date': selectedDate.toString(),
                        });
                        _scheduleNotification(
                            titleController.text, selectedDate!);
                        _fetchTasks();
                        titleController.clear();
                        descriptionController.clear();
                        selectedDate = null;
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Please Fill up Appropriate Information !'),
                            duration: Duration(seconds: 2), // SnackBar duration
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                // Code to execute when the action button is pressed
                                print('Undo action triggered');
                              },
                            ),
                          ),
                        );
                      }

                      setState(() {
                        bottomSheetTap = false;
                      });
                    },
                    child: Container(
                      height: 25,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Color(0xFF33CCCC),
                          borderRadius: BorderRadius.circular(50)),
                      child: Center(
                        child: Text(
                          "Done",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              : Container()
        ],
      ),
      body: tasks.isEmpty
          ? Center(
              child: bottomSheetTap
                  ? Container()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text("There is no tasks list yet !")],
                    ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    leading: Icon(
                      Icons.rectangle_outlined,
                      size: 20,
                    ),
                    title: Text(task['title']),
                    subtitle: Text(task['description'] ?? ''),
                    trailing: IconButton(onPressed:(){
                    },icon: Icon(Icons.star_border,color:Colors.black45,)),
                    // trailing: IconButton(
                    //   icon: Icon(Icons.delete),
                    //   onPressed: () {
                    //     _confirmDelete(task['id']);
                    //   },
                    // ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => TaskDeleteScreen(
                                  task: task, groupID: widget.groupId)));
                      // _editTask(task);
                    },
                  );
                },
              ),
            ),

      bottomSheet: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: GestureDetector(
          onTap: () {
            if (bottomSheetTap) {
              print("nothing");
            } else {
              print("object");
              setState(() {
                bottomSheetTap = true;
              });
            }
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: bottomSheetTap ? 150 : 35,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: bottomSheetTap
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.black)),
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    onChanged: (value) {
                                      setState(() {
                                        print(value);
                                      });
                                    },
                                    controller: titleController,
                                    decoration:
                                        InputDecoration(hintText: "Task Name"),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12.0, top: 10),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: titleController.text.isNotEmpty
                                        ? Color(0xFF33CCCC)
                                        : null,
                                    size: 20,
                                  ),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.black)),
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    onChanged: (value) {
                                      setState(() {
                                        print(value);
                                      });
                                    },
                                    controller: descriptionController,
                                    decoration: InputDecoration(
                                        hintText: "Task Description"),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12.0, top: 12),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: descriptionController.text.isNotEmpty
                                        ? Color(0xFF33CCCC)
                                        : null,
                                    size: 20,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () async {
                                  selectedDate = await _selectDateTime(context);
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.notifications_none_outlined,
                                  color: selectedDate != null
                                      ? Color(0xFF33CCCC)
                                      : null,
                                )),
                            IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.sticky_note_2_outlined,
                                  color: titleController.text.isNotEmpty &&
                                          descriptionController.text.isNotEmpty
                                      ? Color(0xFF33CCCC)
                                      : null,
                                )),
                            IconButton(
                                onPressed: () async {
                                  selectedDate = await _selectDateTime(context);
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.calendar_month,
                                  color: selectedDate != null
                                      ? Color(0xFF33CCCC)
                                      : null,
                                )),
                          ],
                        )
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          height: 26,
                          width: 26,
                          decoration: BoxDecoration(
                              color: Color(0xFF33CCCC),
                              boxShadow: [BoxShadow(color: Colors.black12)],
                              borderRadius: BorderRadius.circular(100)),
                          child: Center(
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Add to Task",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 13,
                              color: Color(0xFF575767)),
                        )
                      ],
                    ),
            ),
          ),
        ),
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: _createTask,
      //   child: Icon(Icons.add),
      // ),
    );
  }

  Future<DateTime?> _selectDateTime(BuildContext context,
      [DateTime? initialDate]) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        return DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
            pickedTime.hour, pickedTime.minute);
      }
    }
    return null;
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
}
