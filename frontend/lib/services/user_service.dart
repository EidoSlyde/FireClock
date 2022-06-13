import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart';

class User {
  final int userId;
  final String username;
  final String email;

  User({
    required this.userId,
    required this.username,
    required this.email,
  });

  static User fromJSON(dynamic json) {
    return User(
      userId: json["user_id"],
      email: json["email"],
      username: json["username"],
    );
  }
}

abstract class UserService {
  abstract final Stream<User?> currentUser;
  Future<void> login(String user, String password);
  Future<void> logout();
  Future<void> register(String username, String email, String password);
}

class DummyUserService extends UserService {
  final BehaviorSubject<User?> _me = BehaviorSubject<User?>()
    ..add(User(username: "Eidos", email: "imeidos@pm.me", userId: 1));
  @override
  Stream<User?> get currentUser => _me;

  @override
  Future<void> login(String user, String password) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> register(String username, String email, String password) async {}
}

final Provider<UserService> userServiceProvider =
    Provider((ref) => DummyUserService());
