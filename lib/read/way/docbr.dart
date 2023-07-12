import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:unrar_file/unrar_file.dart';
import 'package:uuid/uuid.dart';

import 'dosql.dart';

//解包压缩包等待处理
Future<String> newcbr(List filepath) async {
  //获取临时文件夹路径
  final Directory tempDir =
      await getTemporaryDirectory(); // Use an InputFileStream to access the zip file without storing it in memory.
  Directory directory = new Directory('${tempDir.path}/cbr');
  try {
    directory.deleteSync(recursive: true);
  } catch (e) {
    print("1");
  }
  directory.createSync();

  //创建zip临时目录
  File orgepub = File(filepath[0]);
  Directory outdic = new Directory('${tempDir.path}/cbr/out/');
  outdic.createSync();
  //创建空文件
  print("解压前");
  orgepub.copySync('${tempDir.path}/cbr/1.rar');
  //将文件复制到临时目录下等待解压
  // Extraction may fail, so we use a try/catch PlatformException.
  try {
    await UnrarFile.extract_rar(
        '${tempDir.path}/cbr/1.rar', '${tempDir.path}/cbr/out/',
        password: filepath[1]);
  } catch (e) {
    print("extraction failed $e");
  }

  //文件解压完毕
  print("解压后");
  // Zip a directory to out.zip using the zipDirectory convenience method
  Directory outpath = new Directory('${tempDir.path}/cbr/out/');
  //定义目录
  List<FileSystemEntity> alllist = outpath.listSync();
  bool hasdic = false, haspart = true, wrong = false;
  int dictotal = 0;
  late String dicname;
  alllist.forEach((FileSystemEntity element) {
    FileStat a = element.statSync();
    print(a.type);
    print("if判断");
    RegExp numberExp = new RegExp(r'^[0-9]\d*$');
    if (a.type.toString() == "directory") {
      dictotal++;
      hasdic = true;
      dicname = p.basename(element.path);
      //有文件夹进入章节判断
      if (numberExp.hasMatch(dicname)) {
        //纯数字 当作章节处理
        haspart = true;
      } else {
        wrong = true;
        //未知文件夹 无法处理
      }
    }
  });
  print("开始返回");
  if (wrong) {
    return dicname;
  } else {
    return "RICEOKKK!@#NSQ";
  }
}

Future<String> sortcbr(String basename) async {
  print("运行sort");
  //获取临时文件夹路径
  final Directory tempDir =
      await getTemporaryDirectory(); // Use an InputFileStream to access the zip file without storing it in memory.
  Directory directory = new Directory('${tempDir.path}/cbr/out/');
  //mods1:每个文件每章 mods0:所有文件夹一章
  List<FileSystemEntity> outlist = directory.listSync();
  Map sortmap = {};
  int nowid = 1;
  List<String> zhanjie = [];
  outlist.forEach((FileSystemEntity element) {
    FileStat a = element.statSync();
    //RegExp numberExp = new RegExp(r'^[0-9]\d*$');
    if (a.type.toString() == "directory") {
      //文件夹
      String name = p.basename(element.path);
      sortmap.addAll({
        nowid: name,
      });
      zhanjie.add(name);
      nowid++;
    }
  });

  print("运行getallin");
  //获取临时文件夹路径
  //mods1:每个文件每章 mods0:所有文件夹一章
  nowid = 1;
  Map endmap = {};
  List<String> zhanjiepage = [];
  RegExp imageExp = new RegExp(r'(.*?)\.(png|jpe?g|gif)');
  RegExp numExp = new RegExp(r'[^0-9]');
  outlist.forEach((FileSystemEntity element) {
    FileStat a = element.statSync();
    //RegExp numberExp = new RegExp(r'^[0-9]\d*$');
    if (a.type.toString() != "directory") {
      //文件
      String name = p.extension(element.path);
      String filename = p.basename(element.path);
      filename = filename.replaceAll(new RegExp(r'[^0-9]'), '');
      print(int.parse(filename));
      if (imageExp.hasMatch(name)) {
        endmap.addAll({
          nowid: element.path,
        });
        nowid++;
      }
    }
  });
  zhanjiepage.add(nowid.toString());
  int total = sortmap.length;
  for (int now = 1; now <= total; now++) {
    print("循环");
    Directory nowdic = new Directory(directory.path + '${sortmap[now]}');
    List<FileSystemEntity> filepath = nowdic.listSync();
    filepath.forEach((FileSystemEntity element) {
      var exex = p.extension(element.path);
      print(exex);
      if (imageExp.hasMatch(exex)) {
        print("ADDD");
        endmap.addAll({
          nowid: element.path,
        });
        nowid++;
      }
    });

    if (nowid != 1) {
      print(nowid);
      print("章节增加啦!");
      zhanjiepage.add(nowid.toString());
    }
  }

  print('全部结束');
  print(endmap.toString());
  int endtotal = endmap.length;
  var uuid = Uuid();
  String uid = uuid.v4();
  final Directory docDir = await getApplicationDocumentsDirectory();
  final Directory save1Dir = new Directory('${docDir.path}/comic');
  final Directory saveDir = new Directory('${docDir.path}/comic/$uid');
  final Directory imgdir = new Directory('${docDir.path}/comic/$uid/image');
  save1Dir.createSync();
  saveDir.createSync();
  imgdir.createSync();
  int tosavenumber = 0;
  //复制漫画
  for (int now = 1; now <= endtotal; now++) {
    File oldimgfile = new File(endmap[now]);
    var exex = p.extension(endmap[now]);
    File tosavefile = new File('${imgdir.path}/$tosavenumber$exex');
    tosavefile.createSync();
    oldimgfile.copySync('${imgdir.path}/$tosavenumber$exex');
    tosavenumber++;
  }
  //第一页作为封面
  File oldimgfile1 = new File(endmap[1]);
  var exex1 = p.extension(endmap[1]);
  File tosavefile1 = new File('${saveDir.path}/cover$exex1');
  tosavefile1.createSync();
  oldimgfile1.copySync('${saveDir.path}/cover$exex1');
  print("完成啦");
  print(uid);
  //json生成
  Map<String, dynamic> mangameta = {
    "id": uid,
    "title": basename,
    "author": "unknown",
    "right": "unknown",
    "date": 'unknown',
    'series': 'unknown',
    "cover": 'cover$exex1',
    'pages': endtotal,
    'phapage': json.encode(zhanjiepage),
    'phatitle': json.encode(zhanjie),
    'readpage': "0",
    'percentage': "0%",
  };
  String finalsave = json.encode(mangameta);
  File finalcreate = new File('${saveDir.path}/meta.json');
  finalcreate.createSync();
  finalcreate.writeAsStringSync(finalsave);
  //sql生成
  Map<String, Object?> mangamaps = {
    'uid': uid,
    'title': basename,
    'cover': 'cover$exex1',
    'author': "unknown",
    'readpage': "0",
    'percentage': "0%",
    'time': DateTime.now().microsecondsSinceEpoch,
  };
  insertsql(mangamaps);
  return "OK";
}
