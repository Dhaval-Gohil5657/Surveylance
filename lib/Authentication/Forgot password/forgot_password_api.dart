import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:surveylance/Widgets/toast.dart';
import 'package:surveylance/url.dart';

const String url = "$baseurl/surv/forgetPassword";

Future<Map<String, dynamic>> forgotPassword(String email) async {
  final uri = Uri.parse(url);
  try {
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    final data = jsonDecode(response.body);
    print(response.body);

    if (response.statusCode == 200) {
      showToast(message: '${data["message"]}');
      return {"success": true, "message": data["message"]};
    } else {
      showToast(message: '${data["message"]}');

      return {
        "success": false,
        "message": data["message"] ?? "Something went wrong",
      };
    }
  } catch (e) {
    return {"success": false, "message": "Failed to connect to the server"};
  }
}
