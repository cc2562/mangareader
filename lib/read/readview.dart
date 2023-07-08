import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:glass/glass.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:mangareader/read/way/onlyimg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class readview extends StatefulWidget {
  const readview({super.key});

  @override
  State<readview> createState() => _readviewState();
}

class _readviewState extends State<readview> {
  //控制页面可见
  bool control = false, manchange = false;
  double page = 0, nows = 0;
  int total = 20;
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
    /*
    itemPositionsListener.itemPositions.addListener(() {
      if (manchange) {
        print("忽略");
      } else {
        setState(() {
          page =
              itemPositionsListener.itemPositions.value.first.index.toDouble();
        });
      }
    });
     */
  }

  List imgtest = [
    "https://img1.baidu.com/it/u=277732813,1743527573&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=5c2537991ee121488fccb64485298dd3",
    "https://img1.baidu.com/it/u=4150213847,3988298928&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=0f942eb564dcf8f502c367e33aef0fe9",
    "https://img2.baidu.com/it/u=108142487,1385064156&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=174a2d5069c921dcbb64a5a2bb91c588",
    "https://img1.baidu.com/it/u=2645538630,2991364592&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=eda6e8c762a5f01899143aaee426d321",
    "https://img0.baidu.com/it/u=3481849803,3117762343&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=a6d458f16d75611cf061230377f4954b",
    "https://img1.baidu.com/it/u=1901480004,3631773851&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=1011",
    "https://img1.baidu.com/it/u=277732813,1743527573&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=5c2537991ee121488fccb64485298dd3",
    "https://img1.baidu.com/it/u=4150213847,3988298928&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=0f942eb564dcf8f502c367e33aef0fe9",
    "https://img2.baidu.com/it/u=108142487,1385064156&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=174a2d5069c921dcbb64a5a2bb91c588",
    "https://img1.baidu.com/it/u=2645538630,2991364592&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=eda6e8c762a5f01899143aaee426d321",
    "https://img0.baidu.com/it/u=3481849803,3117762343&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=a6d458f16d75611cf061230377f4954b",
    "https://img1.baidu.com/it/u=1901480004,3631773851&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=1011",
    "https://img1.baidu.com/it/u=277732813,1743527573&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=5c2537991ee121488fccb64485298dd3",
    "https://img1.baidu.com/it/u=4150213847,3988298928&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=0f942eb564dcf8f502c367e33aef0fe9",
    "https://img2.baidu.com/it/u=108142487,1385064156&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=174a2d5069c921dcbb64a5a2bb91c588",
    "https://img1.baidu.com/it/u=2645538630,2991364592&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=eda6e8c762a5f01899143aaee426d321",
    "https://img0.baidu.com/it/u=3481849803,3117762343&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=a6d458f16d75611cf061230377f4954b",
    "https://img1.baidu.com/it/u=1901480004,3631773851&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=1011",
    "https://img1.baidu.com/it/u=277732813,1743527573&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=5c2537991ee121488fccb64485298dd3",
    "https://img1.baidu.com/it/u=4150213847,3988298928&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=0f942eb564dcf8f502c367e33aef0fe9",
    "https://img2.baidu.com/it/u=108142487,1385064156&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=174a2d5069c921dcbb64a5a2bb91c588",
    "https://img1.baidu.com/it/u=2645538630,2991364592&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=eda6e8c762a5f01899143aaee426d321",
    "https://img0.baidu.com/it/u=3481849803,3117762343&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=a6d458f16d75611cf061230377f4954b",
    "https://img1.baidu.com/it/u=1901480004,3631773851&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=1011"
  ];
  Widget viewlist() {
    return ScrollablePositionedList.builder(
      itemPositionsListener: itemPositionsListener,
      physics: PageScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemScrollController: jumplist,
      scrollOffsetController: scrollOffsetController,
      itemBuilder: (context, now) {
        return Container(
          width: 100.w,
          height: 100.h,
          child: Stack(
            children: [
              Container(
                width: 100.w,
                height: 100.h,
                child: Image(
                  image: NetworkImage(imgtest[now]),
                  fit: BoxFit.contain,
                ),
              ),
              Text(
                now.toString(),
                style: TextStyle(color: Colors.white, fontSize: 38.sp),
              )
            ],
          ),
        );
      },
      itemCount: total,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                child: viewlist()),
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
                                          "1话 这是一本测试漫画",
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
                                          onPressed: () {},
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
                                    print("12113");
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
                                      control = !control;
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
            Offstage(
              // If the widget is visible, animate to 0.0 (invisible).
              // If the widget is hidden, animate to 1.0 (fully visible).
              //opacity: control ? 0.0 : 1.0,
              //duration: const Duration(milliseconds: 250),
              offstage: control,
              child: Column(
                children: [
                  GestureDetector(
                    child: Container(
                      width: 100.w,
                      height: 25.h,
                      color: Colors.transparent,
                    ),
                    onTap: () {
                      setState(() {
                        page = itemPositionsListener
                            .itemPositions.value.first.index
                            .toDouble();
                        print("YES");
                        control = !control;
                      });
                    },
                  ),
                  Container(
                    width: 100.w,
                    height: 50.h,
                    // color: Colors.red,
                  ),
                  GestureDetector(
                    child: Container(
                      width: 100.w,
                      height: 25.h,
                      color: Colors.transparent,
                    ),
                    onTap: () {
                      setState(() {
                        page = itemPositionsListener
                            .itemPositions.value.first.index
                            .toDouble();
                        control = !control;
                      });
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
