import 'package:flutter/material.dart';
import 'package:todo_loop/data/task.dart';
import 'package:todo_loop/data/task_database.dart';
import 'package:todo_loop/pages/widgets/loading_indicator.dart';
import 'package:todo_loop/pages/widgets/pretty_error.dart';

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  TaskManagementScreenState createState() => TaskManagementScreenState();
}

class TaskManagementScreenState extends State<TaskManagementScreen> {
  static final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  List<Task>? _tasks;
  final List<int> _deletedIds = [];

  Future<void> _selectTime(BuildContext context, Task task) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      setState(() {
        task.time =
            Duration(hours: selectedTime.hour, minutes: selectedTime.minute);
      });
    }
  }

  Future<List<Task>> _loadTasks() async {
    _tasks ??= await TaskDatabaseHelper().getTasks();
    return _tasks!;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (_tasks == null) return;

        //reorder tasks
        _tasks!.asMap().forEach((index, task) => task.position = index);
        //update or insert current tasks
        for (var task in _tasks!) {
          TaskDatabaseHelper().updateTask(task);
        }
        //delete old tasks
        for (var id in _deletedIds) {
          TaskDatabaseHelper().deleteTask(id);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Manage Tasks'),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _tasks?.add(Task(
                      title: "New Task",
                      days: List.generate(7, (index) => false)));
                });
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: FutureBuilder(
          future: _loadTasks(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _tasks = snapshot.data!;

              return Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) {
                      newIndex--;
                    }
                    setState(() {
                      final Task item = _tasks!.removeAt(oldIndex);
                      _tasks!.insert(newIndex, item);
                    });
                  },
                  children: _tasks!.map((task) {
                    return Container(
                        key: ValueKey(task),
                        margin: const EdgeInsets.all(8),
                        child: _buildTaskRow(task, context));
                  }).toList(),
                ),
              );
            } else if (snapshot.hasError) {
              return PrettyError(snapshot.error!, snapshot.stackTrace!);
            } else {
              return const LoadingIndicator();
            }
          },
        ),
      ),
    );
  }

  Widget _buildTaskRow(Task task, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: TextEditingController(text: task.title),
                      onChanged: (value) {
                        task.title = value;
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 17.0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _selectTime(context, task),
                    child: Text(
                      task.time == null
                          ? '00:00'
                          : '${task.time!.inHours}:${(task.time!.inMinutes % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: task.time == null
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (task.time != null)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: IconButton(
                        icon: Icon(Icons.close,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 20),
                        onPressed: () {
                          setState(() {
                            task.time = null;
                          });
                        },
                        padding: EdgeInsets.zero,
                      ),
                    )
                ],
              ),
              Row(
                children: [
                  ReorderableDragStartListener(
                    index: _tasks!.indexOf(task),
                    child: const Icon(Icons.drag_handle),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: List.generate(7, (i) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              task.days[i] = !task.days[i];
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: task.days[i]
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                days[i],
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.delete_outline,
              color: Theme.of(context).colorScheme.secondary, size: 20.0),
          onPressed: () {
            setState(() {
              if (task.id != null) _deletedIds.add(task.id!);
              _tasks!.remove(task);
            });
          },
          padding: const EdgeInsets.only(left: 8, top: 15),
          constraints: const BoxConstraints(),
        )
      ],
    );
  }
}
