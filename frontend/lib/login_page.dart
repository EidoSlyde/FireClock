import 'package:fireclock/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userService = ref.read(userServiceProvider);
    final state = useState<int>(0);
    final error = useState<String?>(null);

    final loginUsername = useTextEditingController();
    final loginPassword = useTextEditingController();

    final registerUsername = useTextEditingController();
    final registerEmail = useTextEditingController();
    final registerPassword = useTextEditingController();

    login() => Column(children: [
          TextField(
            controller: loginUsername,
            decoration: const InputDecoration(labelText: "Username"),
          ),
          TextField(
            controller: loginPassword,
            decoration: const InputDecoration(labelText: "Password"),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              userService
                  .login(loginUsername.text, loginPassword.text)
                  .then((v) => null)
                  .catchError((e) => error.value = e.message);
            },
            child: const Text("OK"),
          ),
        ]);
    register() => Column(children: [
          TextField(
            controller: registerUsername,
            decoration: const InputDecoration(labelText: "Username"),
          ),
          TextField(
            controller: registerEmail,
            decoration: const InputDecoration(labelText: "Email"),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: registerPassword,
            decoration: const InputDecoration(labelText: "Password"),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              userService
                  .register(registerUsername.text, registerEmail.text,
                      registerPassword.text)
                  .then((v) => null)
                  .catchError((e) => error.value = e.message);
            },
            child: const Text("OK"),
          ),
        ]);

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 36),
          ElevatedButton(
            onPressed: () {
              state.value = state.value == 1 ? 0 : 1;
            },
            child: const SizedBox(
                width: 128, height: 72, child: Center(child: Text("Login"))),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              state.value = state.value == 2 ? 0 : 2;
            },
            child: const SizedBox(
                width: 128, height: 72, child: Center(child: Text("Register"))),
          ),
          const SizedBox(height: 42),
          if (state.value == 1) SizedBox(width: 250, child: login()),
          if (state.value == 2) SizedBox(width: 250, child: register()),
          if (error.value != null)
            Text(error.value!, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
