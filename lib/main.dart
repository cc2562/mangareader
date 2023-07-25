import 'dart:io';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mangareader/home/library.dart';
import 'package:mangareader/home/my.dart';
import 'package:mangareader/read/readview.dart';
import 'package:mangareader/read/way/doepub.dart';
import 'package:mangareader/read/way/onlyimg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
          // The Mandy red, light theme.
          theme: FlexThemeData.light(
              scheme: FlexScheme.bahamaBlue, useMaterial3: true),
          // The Mandy red, dark theme.
          darkTheme: FlexThemeData.dark(
              scheme: FlexScheme.mandyRed, useMaterial3: true),
          // Use dark or light theme based on system setting.
          themeMode: ThemeMode.system,
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
  int _currentIndex = 0;
  PageController pagecon = new PageController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
            bottomNavigationBar: SalomonBottomBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() {
                _currentIndex = i;
                pagecon.jumpToPage(i);
              }),
              items: [
                /// Home
                SalomonBottomBarItem(
                  icon: Icon(Icons.book),
                  title: Text("书库"),
                  selectedColor: Colors.purple,
                ),

                /// Profile
                SalomonBottomBarItem(
                  icon: Icon(Icons.person),
                  title: Text("Profile"),
                  selectedColor: Colors.teal,
                ),
              ],
            ),
            body: PageView(
              controller: pagecon,
              children: [libraryview(), myview()],
            )));
  }
}
