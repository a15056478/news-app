import 'dart:convert';

import 'package:http/http.dart';

import '../model/artical_model.dart';
//HTTPS request service
//get HTTPS request

class ApiService {
  final endPointUrl =
      "https://newsapi.org/v2/everything?q=apple&from=2021-03-27&to=2021-03-27&sortBy=popularity&apiKey=b9a187150e3f490bacac1b88a9ab2050";

  Future<List<ArticalModel>> getArtical() async {
    Response res = await get(Uri.parse(endPointUrl));
    if (res.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(res.body);
      List<dynamic> body = json['articles'];
      //get diffrenet articles from the list

      List<ArticalModel> articles =
          body.map((dynamic item) => ArticalModel.fromJson(item)).toList();
      return articles;
    } else {
      throw ("Can't get the Articals");
    }
  }
}
