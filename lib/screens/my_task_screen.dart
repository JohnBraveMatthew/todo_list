import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/screens/add_task_screen.dart';
import 'package:todo_list/utilities/databse_helper.dart';

class MyTasks extends StatefulWidget {
  @override
  _MyTasksState createState() => _MyTasksState();
}

class _MyTasksState extends State<MyTasks> {
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  Future<List<Task>> _taskList;
  DatabaseHelper _dbHelper;

  void _refreshTaskList() async {
    //Future<List<Task>> x = await _dbHelper.fetchTask();
    setState(() {
      _taskList = _dbHelper.fetchTask();
    });
  }

  @override
  void initState() {
    _dbHelper = DatabaseHelper.instance;
    _refreshTaskList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _refreshTaskList();
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddTask(
                          refreshList: _refreshTaskList,
                        )));
          },
          child: Icon(Icons.add),
        ),
        body: FutureBuilder(
          future: _taskList,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final int completedTask = snapshot.data
                .where((Task task) => task.status == 1)
                .toList()
                .length;

            return ListView.builder(
                padding: EdgeInsets.symmetric(
                  vertical: 60,
                  horizontal: 25,
                ),
                itemCount: ++snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "My Tasks",
                          style: TextStyle(fontSize: 40, color: Colors.black),
                        ),
                        Text(
                          "Completed $completedTask of ${snapshot.data.length - 1}",
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ],
                    );
                  }
                  return _buildTask(snapshot.data[index - 1]);
                });
          },
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  Widget _buildTask(Task task) {
    return Padding(
      padding: EdgeInsets.symmetric(),
      child: Material(
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              elevation: 1,
              child: ListTile(
                title: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 18,
                    decoration: task.status == 0
                        ? TextDecoration.none
                        : TextDecoration.lineThrough,
                  ),
                ),
                subtitle:
                    Text("${_dateFormat.format(task.date)} . ${task.priority}",
                        style: TextStyle(
                          fontSize: 15,
                        )),
                trailing: Checkbox(
                  onChanged: (val) {
                    task.status = val ? 1 : 0;
                    _dbHelper.updateTask(task);
                    _refreshTaskList();
                  },
                  value: true,
                  activeColor: Theme.of(context).primaryColor,
                ),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AddTask(
                              task: task,
                              refreshList: _refreshTaskList,
                            ))),
              ),
            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
