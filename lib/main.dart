// import 'package:asd/screen/home.dart';
import 'package:asd/screen/homeScreen.dart';
import 'package:asd/screen/sidebar.dart';
import 'package:asd/screen/timer/timerScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TimerProvider(),
      child: const MyApp(),
    ),
  );
}

// const MyApp(),

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // home: Test(),
      initialRoute: '/',
      routes: {
        '/': (context) => Test(),
        // '/Home': (context) => HomeScreen2(),
        //asd
      },
    );
  }
}
