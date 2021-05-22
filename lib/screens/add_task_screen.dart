import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/utilities/databse_helper.dart';

class AddTask extends StatefulWidget {
  final Function refreshList;
  final Task task;
  AddTask({this.task, this.refreshList});
  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _formKey = GlobalKey<FormState>();
  String _title, _priority;
  int _status;
  DateTime _date = DateTime.now();
  TextEditingController _dateController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  final List<String> _priorities = ["Low", "Medium", "High"];
  DatabaseHelper _dbHelper;

  @override
  void initState() {
    _dbHelper = DatabaseHelper.instance;

    if (widget.task != null) {
      _title = widget.task.title;
      _date = widget.task.date;
      _priority = widget.task.priority;
      _status = widget.task.status;
    }
    _status = 0;

    _dateController.text = _dateFormat.format(_date);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 100, horizontal: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                widget.task == null ? "Add Task" : "Update Task",
                style: TextStyle(
                  fontSize: 30,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: "Task",
                          labelStyle: TextStyle(fontSize: 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      textInputAction: TextInputAction.next,
                      validator: (val) =>
                          (val.isEmpty) ? "please add a task" : null,
                      onSaved: (val) => _title = val,
                      initialValue: _title,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: "Date",
                          labelStyle: TextStyle(fontSize: 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      textInputAction: TextInputAction.next,
                      onTap: _datePicker,
                      controller: _dateController,
                      readOnly: true,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    DropdownButtonFormField(
                      iconEnabledColor: Theme.of(context).primaryColor,
                      iconSize: 25,
                      isDense: true,
                      items: _priorities
                          .map((String priority) => DropdownMenuItem(
                              value: priority,
                              child: Text(
                                priority,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18),
                              )))
                          .toList(),
                      icon: Icon(Icons.arrow_drop_down_circle_outlined),
                      validator: (val) =>
                          (val == null) ? "please add a priority" : null,
                      onSaved: (val) => _priority = val,
                      decoration: InputDecoration(
                          labelText: "Priority",
                          labelStyle: TextStyle(fontSize: 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onChanged: (val) {
                        setState(() {
                          _priority = val;
                        });
                      },
                      value: _priority,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * .07,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: TextButton(
                        child: Text(
                          widget.task == null ? "ADD" : "UPDATE",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: _addTask,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    widget.task != null
                        ? Container(
                            height: MediaQuery.of(context).size.height * .07,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: TextButton(
                              onPressed: _delete,
                              child: Text(
                                "DELETE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _datePicker() async {
    final DateTime date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2050));

    if (date != null && date != _date) {
      _date = date;
    }
    _dateController.text = _dateFormat.format(date);
  }

  _addTask() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Task task = Task(
          title: _title, date: _date, priority: _priority, status: _status);
      if (widget.task == null) {
        _dbHelper.insertTask(task);
      } else {
        task.id = widget.task.id;
        _dbHelper.updateTask(task);
      }
      widget.refreshList();
      print('status is $_status');

      Navigator.pop(context);
    }
  }

  _delete() {
    if (widget.task != null) {
      _dbHelper.deleteTask(widget.task.id);
    }
    widget.refreshList();
    Navigator.pop(context);
  }
}
