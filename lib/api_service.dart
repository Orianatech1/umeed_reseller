import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static String baseUrl = "http://10.0.2.2/umeed/api/";

  static Future login(String email, String password) async {

    try {

      var response = await http.post(
          Uri.parse(baseUrl + "login"),
          body: {
            "email": email,
            "password": password
          }
      );

      print("LOGIN RESPONSE:");
      print(response.body);

      if(response.statusCode == 200){
        return jsonDecode(response.body);
      } else {
        return null;
      }

    } catch(e) {

      print("LOGIN ERROR:");
      print(e);

      return null;

    }

  }

  static Future topReseller() async {
    var response = await http.get(Uri.parse(baseUrl + "top-reseller"));
    return jsonDecode(response.body);
  }

  static Future topProduct() async {
    var response = await http.get(Uri.parse(baseUrl + "top-product"));
    return jsonDecode(response.body);
  }

  static Future myEarnings(id) async {
    var response = await http.get(Uri.parse(baseUrl + "my-earnings/$id"));
    return jsonDecode(response.body);
  }

  static Future createLead(data) async {

    var response = await http.post(

        Uri.parse(baseUrl + "create-lead"),

        headers: {
          "Content-Type": "application/json"
        },

        body: jsonEncode(data)

    );

    return jsonDecode(response.body);

  }

  static Future getProducts() async {

    var response = await http.get(
        Uri.parse(baseUrl+"mobile-products")
    );

    return jsonDecode(response.body);

  }

  static Future searchProducts(query) async {

    var response = await http.get(
        Uri.parse(baseUrl+"search-products/$query")
    );

    return jsonDecode(response.body);

  }

  static Future createSale(data) async {

    var response = await http.post(
      Uri.parse(baseUrl + "create-sale"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode(data),
    );

    print("STATUS CODE: ${response.statusCode}");
    print("RAW RESPONSE:");
    print(response.body);

    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }

    return null;

  }

}