import 'package:flutter/material.dart';
import 'package:mangareader/read/readview.dart';
import 'package:mangareader/read/way/onlyimg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          home: Home_Top(),
        );
      },
    );
  }
}

class Home_Top extends StatefulWidget {
  const Home_Top({super.key});

  @override
  State<Home_Top> createState() => _Home_TopState();
}

class _Home_TopState extends State<Home_Top> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => readview()));
        },
        child: Text("123"));
  }
}
