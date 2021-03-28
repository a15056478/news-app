import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:weather/screens/homepage.dart';

void backgroundFtechHeadLessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    BackgroundFetch.finish(taskId);

    return;
  }
  BackgroundFetch.finish(taskId);
}

void main() {
  runApp(MyApp());
  BackgroundFetch.registerHeadlessTask(backgroundFtechHeadLessTask);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
