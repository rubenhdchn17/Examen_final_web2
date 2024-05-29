import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'screens/landingPage.dart';
import 'widgets/HomeScreen.dart';

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/*
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

 */