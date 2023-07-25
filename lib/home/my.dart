import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class myview extends StatefulWidget {
  const myview({super.key});

  @override
  State<myview> createState() => _myviewState();
}

class _myviewState extends State<myview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("设置"),
        ),
        body: ListView(
          children: [
            ListTile(
              title: Text("软件版本"),
              subtitle: Text("1.0.5"),
              leading: Icon(Icons.archive),
            ),
            ListTile(
              title: Text("仓库地址"),
              subtitle: Text("https://github.com/cc2562/mangareader"),
              leading: Icon(Icons.open_in_new_outlined),
            ),
            ListTile(
              title: Text("软件作者"),
              subtitle: Text("CC米饭"),
              leading: Icon(Icons.person),
            ),
            ListTile(
              title: Text("米饭的博客"),
              subtitle: Text("https://www.ccrice.com"),
              leading: Icon(Icons.link),
            ),
          ],
        ));
  }
}
