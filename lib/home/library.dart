import 'dart:io';

import 'package:appcenter_sdk_flutter/appcenter_sdk_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangareader/read/way/docbr.dart';
import 'package:mangareader/read/way/docbz.dart';
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
  String digshow = "支持 epub zip cbz格式的导入";
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
    //print(conDir);
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
                    await allsec(result.files.single.path!);
                    await getall();
                    Navigator.pop(context);
                  } else if (exee == ".zip") {
                    //密码输入
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (ctx) {
                          String pwd = "", mods = "0";
                          return WillPopScope(
                              child: SimpleDialog(
                                title: Text("导入ZIP文件"),
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(2.w),
                                    child: Column(
                                      children: [
                                        Text(
                                            "如果你的zip文件有密码保护请在下方输入,如果没有请直接点击确定"),
                                        TextField(
                                          onChanged: (value) {
                                            pwd = value;
                                            mods = "1";
                                          },
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              Future.delayed(
                                                  Duration(milliseconds: 500),
                                                  () async {
                                                try {
                                                  String zipone = await newzip([
                                                    result.files.single.path!,
                                                    pwd,
                                                    mods
                                                  ]);
                                                  print(zipone);
                                                  var basename = p.basename(
                                                      result
                                                          .files.single.path!);
                                                  await sortpart(basename);
                                                } catch (e) {
                                                  //Navigator.pop(context);
                                                  print("错误!!!!!!!!!!!!!!!");
                                                  await AppCenterCrashes
                                                      .trackException(
                                                    message: e.toString(),
                                                    type: e.runtimeType,
                                                    //stackTrace: e.toString(),
                                                  );
                                                  print(e);
                                                }
                                                await getall();
                                                Navigator.pop(context);
                                              });
                                            },
                                            child: Text("确定"))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              onWillPop: () async => false);
                        });
                  } else if (exee == ".cbz") {
                    String cbzone = await newcbz(result.files.single.path!);
                    print(cbzone);
                    var basename = p.basename(result.files.single.path!);
                    await sortcbz(basename);
                    await getall();
                    Navigator.pop(context);
                  } /*else if (exee == ".rar" || exee == ".cbr") {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (ctx) {
                          String pwd = "", mods = "0";
                          return WillPopScope(
                              child: SimpleDialog(
                                title: Text('导入${exee.replaceAll(".", "")}文件'),
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(2.w),
                                    child: Column(
                                      children: [
                                        Text("如果你的文件有密码保护请在下方输入,如果没有请直接点击确定"),
                                        TextField(
                                          onChanged: (value) {
                                            pwd = value;
                                            mods = "1";
                                          },
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              Future.delayed(
                                                  Duration(milliseconds: 500),
                                                  () async {
                                                String zipone = await newcbr([
                                                  result.files.single.path!,
                                                  pwd,
                                                  mods
                                                ]);
                                                print(zipone);
                                                var basename = p.basename(
                                                    result.files.single.path!);
                                                await sortcbr(basename);
                                                await getall();
                                                Navigator.pop(context);
                                              });
                                            },
                                            child: Text("确定"))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              onWillPop: () async => false);
                        });
                  } */
                  else {
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
                                        overflow: TextOverflow.fade,
                                        softWrap: false,
                                        maxLines: 2,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        details['author'],
                                        overflow: TextOverflow.fade,
                                        softWrap: false,
                                        maxLines: 2,
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
                onLongPress: () {
                  showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (ctx) {
                        String pwd = "", mods = "0";
                        return WillPopScope(
                            child: AlertDialog(
                              title: Text("删除漫画"),
                              content: Text('确定要删除${details['title']}这一本漫画吗？'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("取消")),
                                TextButton(
                                    onPressed: () async {
                                      bool succ =
                                          await delcomic(details['uid']);
                                      if (succ) {
                                        getall();
                                      }
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "确定删除",
                                      style: TextStyle(color: Colors.red),
                                    ))
                              ],
                            ),
                            onWillPop: () async => true);
                      });
                },
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
