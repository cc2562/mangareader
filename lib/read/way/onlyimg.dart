import 'package:flutter/cupertino.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class imgview extends StatefulWidget {
  const imgview({super.key});

  @override
  State<imgview> createState() => _imgviewState();
}

class _imgviewState extends State<imgview> {
  int total = 10000;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: PageScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, now) {
        return Container(
          width: 100.w,
          height: 100.h,
          child: Image(
            image: NetworkImage(
                "https://img1.baidu.com/it/u=277732813,1743527573&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1688922000&t=5c2537991ee121488fccb64485298dd3"),
            fit: BoxFit.contain,
          ),
        );
      },
      itemCount: total,
    );
  }
}
