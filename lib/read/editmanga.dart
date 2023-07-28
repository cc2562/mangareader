import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mangareader/read/way/dosql.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class editmanga extends StatefulWidget {
  Map conmicmeta = {};
  editmanga({super.key, required this.conmicmeta});

  @override
  State<editmanga> createState() => _editmangaState();
}

class _editmangaState extends State<editmanga> {
  @override
  Widget build(BuildContext context) {
    String title = widget.conmicmeta['title'];
    String author = widget.conmicmeta['author'];
    TextEditingController titlecon =
        new TextEditingController(text: widget.conmicmeta['title']);
    TextEditingController authorcon =
        new TextEditingController(text: widget.conmicmeta['author']);
    print(widget.conmicmeta);
    return Scaffold(
        appBar: AppBar(
          title: Text("修改漫画元信息"),
          leading: Icon(Icons.edit),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(3.w, 1.h, 3.w, 0),
          child: ListView(
            children: [
              TextField(
                onChanged: (element) {
                  title = element;
                },
                controller: titlecon,
                decoration: InputDecoration(
                  label: Text('漫画名'),
                  hintText: widget.conmicmeta['title'],
                ),
              ),
              TextField(
                onChanged: (element) {
                  author = element;
                },
                controller: authorcon,
                decoration: InputDecoration(
                  label: Text('作者'),
                  hintText: widget.conmicmeta['author'],
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              MaterialButton(
                onPressed: () async {
                  final Directory docDir =
                      await getApplicationDocumentsDirectory();
                  final Directory saveDir = new Directory(
                      '${docDir.path}/comic/' + widget.conmicmeta['uid']);
                  File finalcreate = new File('${saveDir.path}/meta.json');
                  String metafile = await finalcreate.readAsString();
                  Map metamap = json.decode(metafile);
                  print(metamap);
                  metamap['title'] = title;
                  metamap['author'] = author;
                  Map<String, Object?> dochange = {
                    'uid': widget.conmicmeta['uid'],
                    'title': title,
                    'author': author,
                  };
                  //
                  print(metamap);
                  String finalsave = json.encode(metamap);
                  await finalcreate.delete();
                  finalcreate.createSync();
                  finalcreate.writeAsStringSync(finalsave);
                  changeread(dochange);
                  Navigator.pop(context);
                },
                child: Row(
                  children: [Icon(Icons.check), Text('确定修改')],
                ),
              )
            ],
          ),
        ));
  }
}
