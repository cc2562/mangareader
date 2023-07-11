import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangareader/read/way/dosql.dart';
import 'package:mangareader/read/way/dozip.dart';
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
  String digshow = "支持 epub zip rar cbz cbr格式的导入";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getall();
  }

  Future<bool> getall() async {
    allconmics = await allconmic();
    setState(() {
      allconmics = allconmics;
    });
    docDir = await getApplicationDocumentsDirectory();
    conDir = new Directory('${docDir.path}/comic');
    print(conDir);
    return true;
  }

  String showpage(String percentage) {
    String thing = percentage.replaceAll("%", '');
    double percent = double.parse(thing);
    if (percent >= 100) {
      return "已读完";
    }
    print(percent);
    return percentage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("米饭漫画"),
        actions: [
          IconButton(
              onPressed: () async {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (ctx) {
                      return WillPopScope(
                          child: SimpleDialog(
                            children: [
                              Container(
                                margin: EdgeInsets.all(2.w),
                                child: Column(
                                  children: [Text("正在导入中"), Text(digshow)],
                                ),
                              ),
                            ],
                          ),
                          onWillPop: () async => false);
                    });
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles();
                if (result != null) {
                  String exee = p.extension(result.files.single.path!);
                  print(result.files.single.path!);
                  print(exee);
                  if (exee == ".epub") {
                    setState(() {
                      //digshow = "正在导入epub格式文件。解析epub文件需要一定时间，请耐心等待";
                    });

                    await allsec(result.files.single.path!);
                    setState(() {
                      //digshow = "正在进行最后的操作";
                    });
                    await getall();

                    Navigator.pop(context);
                  } else if (exee == ".zip") {
                    setState(() {
                      // digshow = "正在导入zip格式文件。解压文件需要一定时间，请耐心等待";
                    });

                    String zipone = await newzip(result.files.single.path!);
                    print(zipone);
                    setState(() {
                      //digshow = "正在分析文件路径并整理所有文件";
                    });
                    var basename = p.basename(result.files.single.path!);
                    await sortpart(basename);
                    setState(() {
                      //digshow = "正在进行最后的操作";
                    });
                    await getall();
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                  }
                  //File file = File(result.files.single.path!);
                } else {
                  // User canceled the picker
                  Navigator.pop(context);
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
                childAspectRatio: 0.70,
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
                  height: 100.h,
                  width: 100.w,
                  child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.fromLTRB(2.w, 0, 2.w, 0),
                          child: Stack(
                            children: [
                              Container(
                                width: 100.w,
                                height: 16.h,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(1.w, 0, 1.w, 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        details['title'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        details['author'],
                                        style: TextStyle(
                                          color: Colors.grey.shade100,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 4.0,
                                      ),
                                    ],
                                    color: Theme.of(context).primaryColor),
                              ),
                              Container(
                                width: 100.w,
                                height: 16.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: FileImage(File(coverpath))),
                                ),
                              ),
                            ],
                          )),
                      Container(
                        padding: EdgeInsets.fromLTRB(2.w, 0, 0, 0),
                        width: 100.w,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [Text(showpage(details['percentage']))],
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => readview(
                                conmicmeta: details,
                              ))).then((value) {
                    showDialog(
                        context: context,
                        builder: (ctx) {
                          return SimpleDialog(
                            children: [
                              Container(
                                width: 15.w,
                                height: 15.w,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              )
                            ],
                          );
                        });

                    Future.delayed(Duration(milliseconds: 500), () {
                      setState(() async {
                        getall();
                        Navigator.pop(context);
                      });
                    });
                  });
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
