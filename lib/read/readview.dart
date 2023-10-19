import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:mangareader/read/editmanga.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:mangareader/read/way/dosql.dart';
import 'package:mangareader/read/way/onlyimg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class readview extends StatefulWidget {
  Map conmicmeta = {};
  //readview({super.key,required conmicmeta});
  readview({Key? key, required this.conmicmeta}) : super(key: key);
  @override
  State<readview> createState() => _readviewState();
}

class _readviewState extends State<readview> {
  //控制页面可见
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool control = false,
      manchange = false,
      hasloading = false,
      janpanmode = false,
      shumode = false;
  double page = 0, nows = 0;
  ScrollPhysics pagephy = PageScrollPhysics();
  Axis pageaxis = Axis.horizontal;
  String nowimagepath = "";
  int total = 1;
  List imagelist = [], phatitle = [], phapage = [];
  Map<dynamic, dynamic> tmpmap = {};
  late Directory docDir, conDir;
  final ItemScrollController jumplist = new ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  //列表控制项目
  //测试数据
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.conmicmeta);
    tmpmap = Map.of(widget.conmicmeta);
    getall();
  }

  void getall() async {
    docDir = await getApplicationDocumentsDirectory();
    conDir = new Directory('${docDir.path}/comic/${widget.conmicmeta['uid']}');
    File metafile = new File('${conDir.path}/meta.json');
    String metastr = metafile.readAsStringSync();
    Map meta = json.decode(metastr);
    print(meta);
    total = meta['pages'];
    phatitle = json.decode(meta['phatitle']);
    phapage = json.decode(meta['phapage']);
    print(phapage);
    print(phatitle);
    Stream<FileSystemEntity> fileList =
        Directory('${conDir.path}/image/').list();

    await for (FileSystemEntity fileSystemEntity in fileList) {
      //print('$fileSystemEntity');
      imagelist.add(fileSystemEntity.path);
    }
    print(widget.conmicmeta);
    print("WAN");
    //日版判断
    if (widget.conmicmeta['readmoe'] == 1) {
      janpanmode = true;
    } else {
      janpanmode = false;
    }
    if (widget.conmicmeta['shumode'] == 1) {
      setState(() {
        shumode = true;
        pagephy = BouncingScrollPhysics();
        pageaxis = Axis.vertical;
      });
    } else {
      setState(() {
        shumode = false;
        pagephy = PageScrollPhysics();
        pageaxis = Axis.horizontal;
      });
    }

    setState(() {
      tmpmap['title'] = meta['title'];
      //tmpmap['author'] = meta['author'];
      hasloading = true;
      // jumpit();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print(itemPositionsListener.itemPositions.value.first.index.toString());
    print(
        (itemPositionsListener.itemPositions.value.first.index / total) * 100);
    double perr =
        (itemPositionsListener.itemPositions.value.first.index / (total - 1)) *
            100;
    String endpage = perr.toStringAsFixed(1) + "%";
    Map<String, Object?> dochange = {
      'uid': widget.conmicmeta['uid'],
      'readpage':
          itemPositionsListener.itemPositions.value.first.index.toString(),
      'percentage': endpage,
      'time': DateTime.now().microsecondsSinceEpoch,
    };
    changeread(dochange);
  }

  Widget viewlist() {
    return ScrollablePositionedList.builder(
      reverse: janpanmode,
      initialScrollIndex: int.parse(widget.conmicmeta['readpage']),
      itemPositionsListener: itemPositionsListener,
      physics: pagephy,
      //
      scrollDirection: pageaxis,
      itemScrollController: jumplist,
      scrollOffsetController: scrollOffsetController,
      itemBuilder: (context, now) {
// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar
        if (shumode) {
          return Container(
            width: 100.w,
            //height: 100.h,
            child: Stack(
              children: [
                Container(
                  width: 100.w,
                  //height: 100.h,
                  child: Image(
                    image: FileImage(File(imagelist[now])),
                    //fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            width: 100.w,
            height: 100.h,
            child: Stack(
              children: [
                Container(
                  width: 100.w,
                  //height: 100.h,
                  child: PhotoView(
                    imageProvider: FileImage(File(imagelist[now])),
                    //fit: BoxFit.contain,
                  ),
                ),
                Container(
                    width: 100.w,
                    //height: 100.h,
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      child: Text(
                        '${now + 1}/$total',
                        style: TextStyle(color: Colors.white, fontSize: 12.sp),
                      ),
                    ))
              ],
            ),
          );
        }
      },
      itemCount: total,
    );
  }

  Widget loading() {
    return Container(
      width: 100.w,
      alignment: Alignment.center,
      height: 100.h,
      child: CircularProgressIndicator(),
    );
  }

  Widget toshow() {
    if (hasloading) {
      return viewlist();
    } else {
      return loading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView.builder(
          itemBuilder: (context, int index) {
            return ListTile(
              onTap: () {
                jumplist.jumpTo(index: int.parse(phapage[index]) - 1);
              },
              title: Text(phatitle[index]),
              subtitle: Text(phapage[index]),
            );
          },
          itemCount: phatitle.length,
        ),
      ),
      body: GestureDetector(
        onTapUp: (de) {
          print("点击");
          final size = MediaQuery.of(context).size;
          final width = size.width;
          final height = size.height;
          double nowpage =
              itemPositionsListener.itemPositions.value.first.index.toDouble();
          print(width / 2);
          final erfen = width / 3;
          final erfenh = height / 5;
          if (de.globalPosition.dx >= erfen &&
              de.globalPosition.dx <= (width - erfen) &&
              de.globalPosition.dy >= (erfenh * 2) &&
              de.globalPosition.dy <= (height - (erfenh * 2))) {
            setState(() {
              page = itemPositionsListener.itemPositions.value.first.index
                  .toDouble();
              control = !control;
            });
          } else {
            if (de.globalPosition.dx >= width / 2 && manchange == false) {
              if (janpanmode) {
                print("JA");
                if (nowpage >= 1 && manchange == false) {
                  jumplist.jumpTo(index: (nowpage - 1).toInt());
                }
              } else {
                print("JN");

                jumplist.jumpTo(index: (nowpage + 1).toInt());
              }
            } else {
              if (janpanmode) {
                jumplist.jumpTo(index: (nowpage + 1).toInt());
              } else {
                if (nowpage >= 1 && manchange == false) {
                  jumplist.jumpTo(index: (nowpage - 1).toInt());
                }
              }
            }
          }
          print(de.globalPosition.dx);
        },
        child: Container(
          width: 100.w,
          height: 100.h,
          child: Stack(
            //顶部层
            children: [
              Container(
                  width: 100.w,
                  //alignment: Alignment.center,
                  height: 100.h,
                  color: Colors.black,
                  child: toshow()),
              //控制层
              Offstage(
                offstage: !control,
                child: AnimatedOpacity(
                  // If the widget is visible, animate to 0.0 (invisible).
                  // If the widget is hidden, animate to 1.0 (fully visible).
                  opacity: control ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //顶部
                      Container(
                          width: 100.w,
                          height: 8.h,
                          color: Colors.black.withOpacity(0.8),
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(2.w, 0.h, 2.w, 0.h),
                              child: Column(
                                children: [
                                  Flex(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    direction: Axis.horizontal,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          //color: Colors.blue,
                                          height: 8.h,
                                          alignment: Alignment.bottomCenter,
                                          child: IconButton(
                                            alignment: Alignment.center,
                                            icon: Icon(
                                              Icons.chevron_left,
                                              color: Colors.white,
                                              size: 8.w,
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                        flex: 1,
                                      ),
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.bottomCenter,
                                          height: 6.h,
                                          //color: Colors.yellow,
                                          child: Text(
                                            tmpmap['title']!,
                                            style: TextStyle(
                                                fontSize: 18.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        flex: 4,
                                      ),
                                      Expanded(
                                        child: Container(
                                          //color: Colors.blue,
                                          height: 8.h,
                                          alignment: Alignment.bottomCenter,
                                          child: IconButton(
                                            alignment: Alignment.center,
                                            icon: Icon(
                                              Icons.more_horiz,
                                              color: Colors.white,
                                              size: 8.w,
                                            ),
                                            onPressed: () {
                                              _scaffoldKey.currentState
                                                  ?.openDrawer();
                                            },
                                          ),
                                        ),
                                        flex: 1,
                                      ),
                                    ],
                                  )
                                ],
                              ))),
                      GestureDetector(
                        child: Container(
                          width: 100.w,
                          height: 79.h,
                          color: Colors.transparent,
                        ),
                        onTap: () {
                          print("显示后展示");
                          setState(() {
                            manchange = false;
                            control = !control;
                          });
                        },
                      ),
                      GlassmorphicContainer(
                        width: 100.w,
                        height: 7.h,
                        alignment: Alignment.center,
                        margin: EdgeInsets.fromLTRB(3.w, 0, 3.w, 1.w),
                        borderRadius: 15,
                        linearGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0x000000).withOpacity(0.5),
                              Color(0x000000).withOpacity(0.5),
                            ],
                            stops: [
                              0.1,
                              1,
                            ]),
                        border: 2,
                        blur: 20,
                        borderGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xff6b81).withOpacity(1),
                              Color(0x6c5ce7).withOpacity(1),
                            ],
                            stops: [
                              0.1,
                              1,
                            ]),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //进度条
                            //设置
                            Flex(
                              direction: Axis.horizontal,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    onPressed: () {
                                      //print("12113");
                                      setState(() {
                                        control = !control;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.chevron_left,
                                      size: 8.w,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      trackHeight: 10,
                                      activeTrackColor:
                                          Colors.grey.withOpacity(0.7),
                                      inactiveTrackColor:
                                          Colors.grey.withOpacity(0.5),
                                      // disabledActiveTrackColor: Colors.yellow,
                                      disabledInactiveTrackColor:
                                          Colors.white.withOpacity(0.8),
                                      activeTickMarkColor: Colors.transparent,
                                      inactiveTickMarkColor: Colors.transparent,
                                      overlayColor: Colors.grey,
                                      overlappingShapeStrokeColor: Colors.black,
                                      overlayShape: RoundSliderOverlayShape(),
                                      // /valueIndicatorColor: Colors.yellow,
                                      //valueIndicatorShape:Colors.white.withOpacity(0.8),
                                      thumbColor: Colors.grey.withOpacity(1),
                                      thumbShape: RoundSliderThumbShape(
                                          //  滑块形状，可以自定义
                                          enabledThumbRadius: 1.5.h // 滑块大小
                                          ),
                                      showValueIndicator:
                                          ShowValueIndicator.onlyForDiscrete,
                                      minThumbSeparation: 100,
                                      rangeTrackShape:
                                          RoundedRectRangeSliderTrackShape(),
                                    ),
                                    child: Slider(
                                      divisions: total,
                                      label: (page.toInt() + 1).toString(),
                                      value: page,
                                      max: total.toDouble() - 1,
                                      min: 0,
                                      onChanged: (double value) {
                                        setState(() {
                                          manchange = true;
                                          page = value;
                                        });
                                      },
                                      onChangeEnd: (double pages) {
                                        int pag = pages.toInt();
                                        print(pag);
                                        setState(() {
                                          jumplist.jumpTo(
                                            index: pag,
                                          );
                                          manchange = false;
                                        });
                                      },
                                    ),
                                  ),
                                  flex: 4,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    onPressed: () {
                                      print("12113");
                                      setState(() {
                                        control = !control;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.chevron_right,
                                      size: 8.w,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    onPressed: () {
                                      print("12113");
                                      setState(() {
                                        showCupertinoModalBottomSheet(
                                          context: context,
                                          builder: (context) => Scaffold(
                                            appBar: AppBar(
                                              leading: Icon(Icons.settings),
                                              title: Text("阅读设置"),
                                            ),
                                            body: SingleChildScrollView(
                                                controller:
                                                    ModalScrollController.of(
                                                        context),
                                                child: Container(
                                                  child: Column(
                                                    children: [
                                                      ListView(
                                                        shrinkWrap: true,
                                                        physics:
                                                            NeverScrollableScrollPhysics(),
                                                        children: [
                                                          ListTile(
                                                            title: Text(
                                                                "将当前页面设置为封面"),
                                                            subtitle: Text(
                                                                "设置新的漫画封面"),
                                                            leading: Icon(
                                                                Icons.image),
                                                            trailing: Icon(Icons
                                                                .chevron_right),
                                                            onTap: () async {
                                                              int nindex =
                                                                  itemPositionsListener
                                                                      .itemPositions
                                                                      .value
                                                                      .first
                                                                      .index;
                                                              nowimagepath =
                                                                  imagelist[
                                                                      nindex];
                                                              File tmpfile =
                                                                  new File(
                                                                      nowimagepath);
                                                              var name =
                                                                  p.basename(
                                                                      tmpfile
                                                                          .path);
                                                              var exnow =
                                                                  p.extension(
                                                                      tmpfile
                                                                          .path);
                                                              Map<String,
                                                                      Object?>
                                                                  dochange = {
                                                                'uid': widget
                                                                        .conmicmeta[
                                                                    'uid'],
                                                                'cover':
                                                                    '/image/$name',
                                                              };
                                                              Navigator.pop(
                                                                  context);
                                                              changeread(
                                                                  dochange);
                                                            },
                                                          ),
                                                          ListTile(
                                                            title:
                                                                Text("修改漫画元信息"),
                                                            subtitle: Text(
                                                                "修改漫画名、作者等信息"),
                                                            leading: Icon(
                                                                Icons.edit),
                                                            trailing: Icon(Icons
                                                                .chevron_right),
                                                            onTap: () {
                                                              showCupertinoModalBottomSheet(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return editmanga(
                                                                          conmicmeta:
                                                                              tmpmap,
                                                                        );
                                                                      })
                                                                  .then((value) =>
                                                                      getall());
                                                            },
                                                          ),
                                                          ListTile(
                                                            title: Text("日漫模式"),
                                                            subtitle:
                                                                Text("更改翻页方向"),
                                                            leading: Icon(Icons
                                                                .chrome_reader_mode_rounded),
                                                            trailing: Switch(
                                                              value: janpanmode,
                                                              onChanged:
                                                                  (bool value) {
                                                                int toset = 0;
                                                                if (value ==
                                                                    true) {
                                                                  toset = 1;
                                                                } else {
                                                                  toset = 0;
                                                                }
                                                                Map<String,
                                                                        Object?>
                                                                    dochange = {
                                                                  'uid': widget
                                                                          .conmicmeta[
                                                                      'uid'],
                                                                  'readmoe':
                                                                      toset
                                                                };
                                                                Navigator.pop(
                                                                    context);
                                                                setState(() {
                                                                  janpanmode =
                                                                      value;
                                                                });
                                                                changeread(
                                                                    dochange);
                                                              },
                                                            ),
                                                          ),
                                                          ListTile(
                                                            title: Text("条漫模式"),
                                                            subtitle:
                                                                Text("更改为上下模式"),
                                                            leading: Icon(Icons
                                                                .chrome_reader_mode_rounded),
                                                            trailing: Switch(
                                                              value: shumode,
                                                              onChanged:
                                                                  (bool value) {
                                                                int toset = 0;
                                                                if (value ==
                                                                    true) {
                                                                  toset = 1;
                                                                } else {
                                                                  toset = 0;
                                                                }
                                                                Map<String,
                                                                        Object?>
                                                                    dochange = {
                                                                  'uid': widget
                                                                          .conmicmeta[
                                                                      'uid'],
                                                                  'shumode':
                                                                      toset
                                                                };
                                                                Navigator.pop(
                                                                    context);
                                                                setState(() {
                                                                  shumode =
                                                                      value;
                                                                });
                                                                changeread(
                                                                    dochange);
                                                                if (shumode) {
                                                                  setState(() {
                                                                    shumode =
                                                                        true;
                                                                    pagephy =
                                                                        BouncingScrollPhysics();
                                                                    pageaxis = Axis
                                                                        .vertical;
                                                                  });
                                                                } else {
                                                                  setState(() {
                                                                    shumode =
                                                                        false;
                                                                    pagephy =
                                                                        PageScrollPhysics();
                                                                    pageaxis = Axis
                                                                        .horizontal;
                                                                  });
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                )),
                                          ),
                                        );
                                      });
                                    },
                                    icon: Icon(
                                      Icons.settings,
                                      size: 8.w,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              //触摸层
            ],
          ),
        ),
      ),
    );
  }
}
