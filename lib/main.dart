import 'package:flutter/material.dart';
import 'package:todo_loop/pages/page_task_list.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _makeTheme(Brightness brightness) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primaryContainer,
          actionsIconTheme:
              IconThemeData(color: colorScheme.onPrimaryContainer)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Loop',
      home: const TodoListScreen(),
      theme: _makeTheme(Brightness.light),
      darkTheme: _makeTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
    );
  }
}
