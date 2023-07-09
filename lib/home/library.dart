import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangareader/read/way/dosql.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:path/path.dart' as p;
import '../read/readview.dart';
import '../read/way/doepub.dart';

class libraryview extends StatefulWidget {
  const libraryview({super.key});

  @override
  State<libraryview> createState() => _libraryviewState();
}

class _libraryviewState extends State<libraryview>
    with AutomaticKeepAliveClientMixin {
  List allconmics = [];
  late Directory docDir, conDir;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getall();
  }

  void getall() async {
    allconmics = await allconmic();
    setState(() {
      allconmics = allconmics;
    });
    docDir = await getApplicationDocumentsDirectory();
    conDir = new Directory('${docDir.path}/comic');
    print(conDir);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("米饭漫画"),
        actions: [
          IconButton(
              onPressed: () async {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles();

                if (result != null) {
                  String exee = p.extension(result.files.single.path!);
                  print(result.files.single.path!);
                  print(exee);
                  if (exee == ".epub") {
                    await allsec(result.files.single.path!);
                    getall();
                  }
                  //File file = File(result.files.single.path!);
                } else {
                  // User canceled the picker
                }
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(3.w, 0, 3.w, 0),
        child: Container(
          width: 100.w,
          height: 100.h,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, //横轴三个子widget
                childAspectRatio: 0.525,
                crossAxisSpacing: 1.w,
                mainAxisSpacing: 1.w),
            itemBuilder: (context, now) {
              print(allconmics[now].toString());
              Map details = allconmics[now];
              String conmicpath = conDir.path + "/${details['uid']}/";
              String coverpath = conmicpath + details['cover'];
              print(conmicpath);
              return GestureDetector(
                child: Container(
                  height: 8.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        fit: BoxFit.cover, image: FileImage(File(coverpath))),
                  ),
                  child: Column(
                    children: [
                      Text(details['title']),
                      Text(details['author']),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => readview(
                                conmicmeta: details,
                              )));
                },
              );
            },
            itemCount: allconmics.length,
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
