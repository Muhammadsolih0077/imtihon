import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const SplashScreen()));
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MyApp()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("rasm/palma2.jpg"), fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Today's Tasks",
            style: TextStyle(
              color: const Color.fromARGB(255, 10, 214, 64),
              fontSize: 25,
              fontWeight: FontWeight.w400,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 28, 28, 28),
          bottom: TabBar(
            tabs: [
              Tab(text: "Personal"),
              Tab(text: "Default"),
              Tab(text: "Study"),
              Tab(text: "Work"),
            ],
            labelColor: Color.fromARGB(255, 10, 214, 64),
            unselectedLabelColor: Color.fromARGB(255, 52, 240, 102),
            indicatorColor: Color.fromARGB(255, 10, 214, 64),
          ),
        ),
        backgroundColor: Colors.black,
        body: TabBarView(
          children: [
            TaskTab(tabName: "Personal"),
            TaskTab(tabName: "Default"),
            TaskTab(tabName: "Study"),
            TaskTab(tabName: "Work"),
          ],
        ),
      ),
    );
  }
}

class TaskTab extends StatefulWidget {
  final String tabName;

  const TaskTab({required this.tabName, super.key});

  @override
  _TaskTabState createState() => _TaskTabState();
}

class _TaskTabState extends State<TaskTab> {
  final List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksString = prefs.getString(widget.tabName);
    if (tasksString != null) {
      List<dynamic> jsonTasks = jsonDecode(tasksString);
      for (var jsonTask in jsonTasks) {
        tasks.add(Map<String, dynamic>.from(jsonTask));
      }
      setState(() {});
    }
  }

  Future<void> saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonTasks = jsonEncode(tasks);
    prefs.setString(widget.tabName, jsonTasks);
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      saveTasks();
    });
  }

  void showTaskDialog(BuildContext context) {
    String title = '';
    String description = '';
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showDialog(
      
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 34, 34, 34),
          title: Text(
            'Adding ${widget.tabName} Task',
            style: TextStyle(color: Color.fromARGB(255, 10, 214, 64)),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    onChanged: (value) {
                      title = value;
                    },
                    decoration: InputDecoration(
                      labelText: 'Task',
                      labelStyle: TextStyle(color: Colors.white),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple)),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextField(
                  onChanged: (value) {
                    description = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.white),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple)),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () async {
                          selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark(),
                                child: child!,
                              );
                            },
                          );
                        },
                        child: Text('Pick Date',
                            style: TextStyle(
                                color: Color.fromARGB(255, 10, 214, 64))),
                      ),
                      InkWell(
                        onTap: () async {
                          selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark(),
                                child: child!,
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 40),
                          child: Text('Pick Time',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 10, 214, 64))),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close', style: TextStyle(color: Colors.purple)),
            ),
            TextButton(
              onPressed: () {
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Task may not be empty')),
                  );
                  return;
                }

                DateTime now = DateTime.now();
                String date = selectedDate != null
                    ? DateFormat('MMMM d, y').format(selectedDate!)
                    : DateFormat('MMMM d, y,').format(now);
                String time = selectedTime != null
                    ? '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                    : '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

                tasks.add({
                  'title': title,
                  'description': description,
                  'date': date,
                  'time': time,
                  'completed': false,
                });

                saveTasks();
                Navigator.pop(context);
                setState(() {});
              },
              child: Text('Add', style: TextStyle(color: Colors.purple)),
            ),
          ],
        );
      },
    );
  }

  void navigateToTaskDetail(Map<String, dynamic> task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(
            task: task, tabName: widget.tabName), // tabName qo'shildi
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasTasks = tasks.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        image: hasTasks
            ? null
            : DecorationImage(
                image: AssetImage("rasm/palma.jpg"),
                fit: BoxFit.cover,
              ),
        color: hasTasks ? Colors.transparent : Colors.black,
      ),
      child: Column(
        children: [
          Expanded(
            child: hasTasks
                ? ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Dismissible(
                        key: Key(task['title']),
                        onDismissed: (direction) {
                          deleteTask(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Task deleted')),
                          );
                        },
                        background: Container(),
                        child: GestureDetector(
                          onTap: () => navigateToTaskDetail(task),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task['title'],
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 10, 214, 64),
                                              decoration: task['completed']
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                              decorationColor: Colors.amber,
                                              fontSize: 17),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '${task['date']}',
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 52, 240, 102),
                                              ),
                                            ),
                                            Text(
                                              ' ${task['time']}',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        task['completed'] = !task['completed'];
                                      });
                                      saveTasks();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          color: task['completed']
                                              ? Colors.green
                                              : Colors.black,
                                          border: Border.all(
                                              color: task['completed']
                                                  ? Colors.black
                                                  : Colors.grey,
                                              width: 2),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(2)),
                                        ),
                                        child: task['completed']
                                            ? Icon(
                                                Icons.check,
                                                color: Colors.black,
                                                size: 16,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      '',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () => showTaskDialog(context),
                child: CircleAvatar(
                  radius: 30,
                  child: Icon(
                    Icons.add,
                    color: Colors.black,
                  ),
                  backgroundColor: Color.fromARGB(255, 10, 214, 64),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class TaskDetailScreen extends StatelessWidget {
  final Map<String, dynamic> task;
  final String tabName; // Yangi parametr

  const TaskDetailScreen(
      {required this.task, required this.tabName, super.key});

  @override
  Widget build(BuildContext context) {
    // Convert time string to DateTime to get AM/PM
    final timeParts = task['time'].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Determine AM or PM
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color.fromARGB(255, 10, 214, 64)),
        backgroundColor: Colors.black,
        title: Text(
          '${tabName} Details', // tabName qo'shildi
          style: TextStyle(color: Color.fromARGB(255, 10, 214, 64)),
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task:',
              style: TextStyle(
                  color: Color.fromARGB(255, 10, 214, 64),
                  fontSize: 22,
                  fontWeight: FontWeight.w500),
            ),
            Text(
              '${task['title']}',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Description:',
              style: TextStyle(
                  color: Color.fromARGB(255, 10, 214, 64),
                  fontSize: 22,
                  fontWeight: FontWeight.w500),
            ),
            Text(
              '${task['description']}',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Date:',
              style: TextStyle(
                  color: Color.fromARGB(255, 10, 214, 64),
                  fontSize: 22,
                  fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Text(
                  '${task['date']} $formattedHour:${minute.toString().padLeft(2, '0')} $amPm',
                  style: TextStyle(
                    color: Color.fromARGB(255, 3, 153, 125),
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
