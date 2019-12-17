import 'package:voicecoin/HomeScreen.dart';
import 'package:flutter/material.dart';
//import 'dart:async';

//import 'package:voicecoin/HomeScreen.dart' as prefix0;


void main() => runApp(new MyApp());
 
class MyApp extends StatelessWidget {
  static String dropdownValue;
  static bool help=false;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false, 
        theme: new ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
          // counter didn't reset back to zero; the application is not restarted.

            primaryColor: Colors.white,
            primaryColorDark: Colors.white30,
            accentColor: Colors.blue

        ),
      home: new Home_Screen(title: 'VoiceCoin'),
    );
  }

  
  
}

