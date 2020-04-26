import 'package:flutter/material.dart';
import 'package:telit/screens/emergency_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'telit',
      theme: ThemeData(

        primaryColor: Colors.green[800],
      ),
      home: EmergencyList(),
    );
  }
}

