import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'FireClock',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const FireClockApp(),
      ),
    );
  }
}

class FireClockApp extends HookConsumerWidget {
  const FireClockApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: MainPage(),
    );
  }
}
