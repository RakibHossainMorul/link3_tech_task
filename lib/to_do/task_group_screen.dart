import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/db_helper.dart';
import 'task_list_screen.dart';

class TaskGroupScreen extends StatefulWidget {
  @override
  _TaskGroupScreenState createState() => _TaskGroupScreenState();
}

class _TaskGroupScreenState extends State<TaskGroupScreen> {
  List<Map<String, dynamic>> taskGroups = [];

  @override
  void initState() {
    super.initState();
    _loadTaskGroups();
  }

  Future<void> _fetchTaskGroups() async {
    final data = await DBHelper.instance.getTaskGroups();
    setState(() {
      taskGroups = data;
    });
  }

  void _deleteTaskGroup(int id) async {
    await DBHelper.instance.deleteTaskGroup(id);
    _fetchTaskGroups();
  }

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool addTaskGroup = false;


  // Load task groups and task counts
  Future<void> _loadTaskGroups() async {
    taskGroups = await DBHelper.instance.getTaskGroups();
    for (var group in taskGroups) {
      // For each group, get the task count
      int taskCount = await DBHelper.instance.getTaskCountForGroup(group['id']);
      taskCounts[group['id']] = taskCount;
    }
    setState(() {});
  }


  Map<int, int> taskCounts = {}; // Store the task counts for each group

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 80,
              color: Color(0xFFF8F8F8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.asset(
                              "assets/dummy.png",
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Zoyeb Ahmed",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                Text(
                                  "5 incomplete, 5 completed",
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal, fontSize: 12),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.search_outlined,
                            size: 35,
                            color: Colors.black,
                          ))
                    ],
                  ),
                ),
              ),
            ),
            Divider(),
            addTaskGroup
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: InputDecoration(hintText: "Title"),
                        ),
                        TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(hintText: "Description"),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (titleController.text.isEmpty &&
                                descriptionController.text.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Please Fillup the Group Title !'),
                                  duration:
                                      Duration(seconds: 2), // SnackBar duration
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () {
                                      // Code to execute when the action button is pressed
                                      print('Undo action triggered');
                                    },
                                  ),
                                ),
                              );
                            } else if (titleController.text.isNotEmpty &&
                                descriptionController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Please Fillup the Group Description !'),
                                  duration:
                                      Duration(seconds: 2), // SnackBar duration
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () {
                                      // Code to execute when the action button is pressed
                                      print('Undo action triggered');
                                    },
                                  ),
                                ),
                              );
                            } else if (titleController.text.isEmpty &&
                                descriptionController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Please Fillup the Group Title & Desccription !'),
                                  duration:
                                      Duration(seconds: 2), // SnackBar duration
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () {
                                      // Code to execute when the action button is pressed
                                      print('Undo action triggered');
                                    },
                                  ),
                                ),
                              );
                            } else {
                              DBHelper.instance.createTaskGroup({
                                'name': titleController.text,
                                'description': descriptionController.text,
                              });

                              _fetchTaskGroups();
                              setState(() {
                                addTaskGroup = false;
                              });
                            }
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Color(0xFF33CCCC))),
                            child: Center(
                              child: Text(
                                "Save Task Group",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF33CCCC),
                                    fontSize: 14),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : Container(),
            taskGroups.isEmpty
                ? addTaskGroup
                    ? Container()
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("There is no any task group added yet !"),
                          ],
                        ),
                      )
                : Expanded(
                    child: ListView.builder(
                      itemCount: taskGroups.length,
                      itemBuilder: (context, index) {
                        final group = taskGroups[index];
                        final taskCount = taskCounts[group['id']] ?? 0; // Get the task count

                        return ListTile(
                          leading: Icon(Icons.list,color: Color(0xFF33CCCC),),
                          title: Text(
                            group['name'],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("hjgd"),
                              Text('$taskCount tasks', style: TextStyle(fontSize: 12, color: Colors.black)),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _confirmDelete(group['id']);
                            },
                          ),
                          onTap: () {
                            Navigator.of(context).push(CupertinoPageRoute(
                              builder: (context) =>
                                  TaskListScreen(groupId: group['id']),
                            ));
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
        ),
        tooltip: "Tap to add new Todo List",
        backgroundColor: Color(0xFF33CCCC),
        onPressed: () {
          setState(() {
            addTaskGroup = true;
          });
        },
        child: Icon(
          Icons.add,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text(
            'Are you sure you want to delete this task group and all its tasks?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteTaskGroup(id);
              Navigator.of(ctx).pop();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
