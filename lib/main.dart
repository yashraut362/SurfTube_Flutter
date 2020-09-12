import 'package:flutter/material.dart';
import 'package:surftube/screens/homescreen.dart';

import 'package:surftube/widgets/Footer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: Footer(),
        body: HomeScreen(),
      ),
    );
  }
}
