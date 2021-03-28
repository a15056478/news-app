import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/artical_model.dart';
import '../service/api_services.dart';
import 'settings.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HomePage extends StatefulWidget {
  final String data;

  const HomePage({Key key, this.data}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ApiService client = ApiService();
  GlobalKey<RefreshIndicatorState> refreshKey;
  Future data;

  @override
  void initState() {
    super.initState();
    refreshKey = GlobalKey<RefreshIndicatorState>();
    data = client.getArtical();
  }

  Future<Null> refreshPage() async {
    await Future.delayed(Duration(seconds: 1));
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsPage()));
              }),
        ],
        title: Text(
          "News App",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: () async {
          setState(() {});
          return await refreshPage();
        },
        child: ListBuilder(width),
      ),
    );
  }

  FutureBuilder<List<ArticalModel>> ListBuilder(double width) {
    return FutureBuilder(
      future: client.getArtical(),
      builder:
          (BuildContext context, AsyncSnapshot<List<ArticalModel>> snapshot) {
        if (snapshot.hasData) {
          List<ArticalModel> articles = snapshot.data;
          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.all(width / 30),
                padding: EdgeInsets.all(width / 30),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(width / 20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3.0,
                      ),
                    ]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: width,
                      child: Image.network(articles[index].urlToImage),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(articles[index].source.name),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      articles[index].title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      articles[index].publishedAt.split('T').first +
                          " " +
                          articles[index]
                              .publishedAt
                              .split('T')
                              .last
                              .split('Z')
                              .first,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )
                  ],
                ),
              );
            },
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
