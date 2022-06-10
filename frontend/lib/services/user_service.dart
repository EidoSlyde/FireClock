import 'package:hooks_riverpod/hooks_riverpod.dart';

class User {
  final int userId;
  final String username;
  final String email;

  User({
    required this.userId,
    required this.username,
    required this.email,
  });
}

abstract class UserService {
  abstract final Stream<User?> currentUser;
}

class DummyUserService extends UserService {
  @override
  Stream<User?> get currentUser =>
      Stream.value(User(username: "Eidos", email: "imeidos@pm.me", userId: 1));
}

final Provider<UserService> userServiceProvider =
    Provider((ref) => DummyUserService());
