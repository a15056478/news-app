import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/artical_model.dart';
import '../service/api_services.dart';
import 'homepage.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<ArticalModel> articalModel;
  ApiService apiService = ApiService();
  bool _enabled = false;
  Future<bool> bgRunStatus;
  bool _reminderEnable = false;
  String title;
  String time;

  _getLatestNews() async {
    await apiService.getArtical().then((value) {
      if (value != null) {
        setState(() {
          title = value[0].title;
          time = value[0].publishedAt;
        });
      }
    });
  }

  _getBackgroundRunStatus() async {
    final preference = await SharedPreferences.getInstance();
    final bgStatus = preference.getBool('bgRunStatus');
    if (bgStatus == null || bgStatus == false) {
      setState(() {
        _enabled = false;
        preference.setBool('bgRunStatus', false);
        print('bgrunStatus change to false');
      });
    } else {
      setState(() {
        _enabled = true;
        preference.setBool('bgRunStatus', true);
        print('bgrunStatus change to true');
      });
    }
  }

  _changeBackgroundStatus() async {
    final preference = await SharedPreferences.getInstance();
    bool status = preference.getBool('bgRunStatus');
    await preference.setBool('bgRunStatus', !status);
    setState(() {
      _enabled = !status;
      print("bg stATUS CHANGED");
    });
  }

  Future<void> initPlatformState() async {
    await BackgroundFetch.configure(
      BackgroundFetchConfig(
          minimumFetchInterval:
              15, //data will be fetch again in backgorund after 15 minutes only
          stopOnTerminate: false,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiredNetworkType: NetworkType.NONE),
      (String taskId) async {
        showNotification(title, time);
        BackgroundFetch.finish(taskId);
      },
    );
  }

  void _onClickEnable(enabled) {
    setState(() {
      _enabled = enabled;
      _changeBackgroundStatus();
    });
    if (enabled) {
      BackgroundFetch.start()
          .then((int value) => print(value))
          .catchError((e) => print("background fetch failure"));
    } else {
      BackgroundFetch.stop().then((value) => print("Backhrounf fetch stop"));
    }
  }

  void _onReminderClickEnable(enabled) {
    setState(() {
      _reminderEnable = enabled;
    });
    if (enabled) {
      scheduleNotification();
    }
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  showNotification(String title, String time) async {
    var android = AndroidNotificationDetails('id', 'channel', 'description',
        priority: Priority.high, importance: Importance.max);
    var platform = NotificationDetails(android: android);
    await flutterLocalNotificationsPlugin
        .show(0, 'Current update', title, platform, payload: time);
  }

  Future onSelectNotification(String data) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) {
        return HomePage(
          data: data,
        );
      }),
    );
  }

  scheduleNotification() async {
    var scheduleNotificationsDateTime = DateTime.now()
        .add(Duration(minutes: 10)); //for reminder notify after 10 minutes
    var androidPlatformChannel = AndroidNotificationDetails(
        'id', 'name', 'description',
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'));
    var platforms = NotificationDetails(android: androidPlatformChannel);
    await flutterLocalNotificationsPlugin.schedule(
      0,
      'News upatde',
      'Check out what is happening around you',
      scheduleNotificationsDateTime,
      platforms,
      androidAllowWhileIdle: true,
    );
  }

  @override
  void initState() {
    super.initState();
    _getLatestNews();
    _getBackgroundRunStatus();
    initPlatformState();

    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initSetttings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          Card(
            margin: EdgeInsets.all(width / 40),
            child: ListTile(
              trailing: Switch(
                value: _enabled,
                onChanged: _onClickEnable,
              ),
              title: Text("Run in background"),
            ),
          ),
          Card(
            margin: EdgeInsets.all(width / 40),
            child: ListTile(
              trailing: Switch(
                value: _reminderEnable,
                onChanged: _onReminderClickEnable,
              ),
              title: Text("Reminder"),
            ),
          )
        ],
      ),
    );
  }
}
