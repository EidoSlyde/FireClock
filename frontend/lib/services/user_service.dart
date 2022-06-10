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
}

abstract class UserService {
  abstract final Stream<User?> currentUser;
}

class DummyUserService extends UserService {
  final BehaviorSubject<User?> _me = BehaviorSubject<User?>()
    ..add(User(username: "Eidos", email: "imeidos@pm.me", userId: 1));
  @override
  Stream<User?> get currentUser => _me;
}

final Provider<UserService> userServiceProvider =
    Provider((ref) => DummyUserService());
