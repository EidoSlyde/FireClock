import 'dart:convert';

import 'package:fireclock/services/http/http_settings.dart';
import 'package:fireclock/services/user_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

class HttpUserService extends UserService {
  final _curr = BehaviorSubject<User?>()..add(null);

  @override
  Stream<User?> get currentUser => _curr;

  @override
  Future<User> login(String user, String password) async {
    final res = await http.post(Uri.parse("$apiUrl/user/login"),
        body: {"username": user, "password": password});
    if (res.statusCode == 400) {
      throw FormatException(jsonDecode(res.body)['message']);
    }
    final u = User.fromJSON(jsonDecode(res.body));
    _curr.add(u);
    return u;
  }

  @override
  Future<void> logout() async {
    _curr.add(null);
  }

  @override
  Future<User> register(String username, String email, String password) async {
    if (username == "") throw const FormatException("Empty username");
    if (password == "") throw const FormatException("Empty password");
    if (email == "") throw const FormatException("Empty email");

    final res = await http.post(Uri.parse("$apiUrl/user"), body: {
      "username": username,
      "email": email,
      "password": password,
    });
    if (res.statusCode != 201) {
      throw FormatException(jsonDecode(res.body)['message']);
    }
    final u = User.fromJSON(jsonDecode(res.body));
    _curr.add(u);
    return u;
  }
}
