import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:todo_loop/data/task.dart';
import 'package:todo_loop/data/task_database.dart';
import 'package:todo_loop/pages/page_task_management.dart';
import 'package:todo_loop/pages/widgets/error_message.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  TodoListScreenState createState() => TodoListScreenState();
}

class TodoListScreenState extends State<TodoListScreen> {
  static final DateTime today = DateTime.now();

  List<Task> _tasks = [];
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 1));
    _refreshTasks();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _refreshTasks() async {
    final List<Task> tasks = await TaskDatabaseHelper().getTasksForToday();

    setState(() {
      _tasks = tasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Daily Todo Loop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar_outlined),
            onPressed: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TaskManagementScreen()))
                  .then((_) => _refreshTasks());
            },
          ),
        ],
      ),
      body: _tasks.isNotEmpty
          ? Stack(children: [
              Positioned(
                top: 0,
                right: 0,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  colors: [
                    colorScheme.primary,
                    colorScheme.secondary,
                    colorScheme.surface,
                    colorScheme.onPrimary,
                    colorScheme.onSecondary,
                    colorScheme.onSurface,
                  ],
                  emissionFrequency: 0.0001,
                  shouldLoop: false,
                  numberOfParticles: 50,
                  maxBlastForce: 50,
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.width * 0.15),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      Task task = _tasks[index];
                      double completionRate =
                          (task.doneCounter + (task.isChecked ? 1 : 0)) /
                              task.showedCounter;

                      return ListTile(
                        leading: Checkbox(
                          value: task.isChecked,
                          onChanged: (value) {
                            setState(() {
                              task.isChecked = value!;
                              _confettiController.stop(clearAllParticles: true);
                              if (_tasks.every((task) => task.isChecked)) {
                                _confettiController.play();
                              }
                            });
                            TaskDatabaseHelper().checkTask(task, value!);
                          },
                        ),
                        trailing: Text(
                          '${(completionRate * 100).toInt()}%',
                          style: TextStyle(
                            color: Color.lerp(
                                Colors.red, Colors.green, completionRate),
                          ),
                        ),
                        title: Row(
                          children: [
                            if (task.time != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  '${task.time!.inHours}:${(task.time!.inMinutes % 60).toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontSize: 20),
                                ),
                              ),
                            Expanded(
                              child: Text(
                                task.title,
                                style: const TextStyle(fontSize: 17.0),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ])
          : const ErrorMessage("Nothing to do today"),
    );
  }
}
