import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:glass/glass.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:mangareader/read/way/dosql.dart';
import 'package:mangareader/read/way/onlyimg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

Future<String> allsec(String filepath) async {
  //获取临时文件夹路径
  final Directory tempDir =
      await getTemporaryDirectory(); // Use an InputFileStream to access the zip file without storing it in memory.
  Directory directory = new Directory('${tempDir.path}/epub');
  if (await File(directory.path).exists()) {
    directory.deleteSync();
    print("文件删除");
  }
  directory.createSync();
  //创建epub临时目录
  File orgepub = File(filepath);
  //创建空文件

  orgepub.copySync('${tempDir.path}/epub/1.zip');
  //将文件复制到临时目录下等待解压
  // Use an InputFileStream to access the zip file without storing it in memory.
  final inputStream = InputFileStream('${tempDir.path}/epub/1.zip');
  // Decode the zip from the InputFileStream. The archive will have the contents of the
  // zip, without having stored the data in memory.
  final archive = ZipDecoder().decodeBuffer(inputStream);
  // For all of the entries in the archive
  for (var file in archive.files) {
    // If it's a file and not a directory
    if (file.isFile) {
      // Write the file content to a directory called 'out'.
      // In practice, you should make sure file.name doesn't include '..' paths
      // that would put it outside of the extraction directory.
      // An OutputFileStream will write the data to disk.
      final outputStream =
          OutputFileStream('${tempDir.path}/epub/out/${file.name}');
      // The writeContent method will decompress the file content directly to disk without
      // storing the decompressed data in memory.
      file.writeContent(outputStream);
      // Make sure to close the output stream so the File is closed.
      outputStream.close();
    }
  }
  Directory directorys = new Directory('${tempDir.path}/epub/out');
  directorys.listSync().forEach((file) {
    //print(file.path);
  });
  //开始进行文件分析
  await doepub('${tempDir.path}/epub/out');
  print("开始批量");
  return "ok";
}

Future<String> doepub(String epubpath) async {
  List<String> fristlist = [], htmllist = [];
  //获取原数据文件
  File metainf = new File('$epubpath/META-INF/container.xml');
  String tese = "!2";
  tese = metainf.readAsStringSync();
  var rootff = RegExp(r'<rootfile full-path=[^>]*>');
  if (rootff.hasMatch(tese)) {
    tese = rootff.stringMatch(tese)!;
    var rootfff = RegExp(r'(?<=full-path=").*?opf(?=")');
    tese = rootfff.stringMatch(tese)!;
  }
  print("结果是：$tese");
  String matapath = epubpath + "/$tese";
  String phapath = epubpath + "/xml/vol.ncx";
  print("路径是:$matapath");
  //获取原数据
  fristlist = await getepubitem(matapath);
  //获取所有页面
  htmllist = await getepubhtml(fristlist);
  //获取封面
  String coverhtml = await getcover(fristlist);
  //获取作者页
  String createhtml = await getcreatby(fristlist);
  //读取每个html获取图片
  List<String> imglist = await getimg(htmllist);
  //获取封面图片
  String coverpath = "nothing", createpath = "nothing";
  List finallist = [];
  if (coverhtml != 'NOCOVER') {
    coverpath = await getsingleimg(coverhtml);
    //finallist.add(coverpath);
  }

  //生成完整图片列表
  imglist.forEach((element) {
    finallist.add(element);
  });
  //获取作者页图片
  if (createhtml != "NOCREATEBY") {
    createpath = await getsingleimg(createhtml);
    finallist.add(createpath);
  }
  Map<String, String> toit = {
    "imglist": json.encode(finallist),
    "matapath": matapath,
    "phapath": phapath,
    "coverpath": coverpath,
    "createpath": createpath,
  };
  //print(finallist.toString());
  print("开始保存");
  await savefile(toit);
  return "ok";
  //保存文件并处理数据库
}

Future<String> savefile(Map<String, String> orgmap) async {
  String title = "unknown",
      author = "unknown",
      right = "unknown",
      date = "unknown",
      series = "unknown";
  //为本漫画生成uid
  var uuid = Uuid();
  String uid = uuid.v4();
  //初始化本漫画的保存路径
  final Directory docDir = await getApplicationDocumentsDirectory();
  final Directory tempDir = await getTemporaryDirectory();
  final Directory save1Dir = new Directory('${docDir.path}/comic');
  final Directory saveDir = new Directory('${docDir.path}/comic/$uid');
  final Directory imgdir = new Directory('${docDir.path}/comic/$uid/image');
  save1Dir.createSync();
  saveDir.createSync();
  imgdir.createSync();
  String matafilepath = orgmap['matapath']!;
  File mata = new File(matafilepath);
  String neirong = mata.readAsStringSync();
  //开始获取原数据
  //获取章节
  File pha = new File(orgmap['phapath']!);
  String pharong = pha.readAsStringSync();
  List phapage = [], phatitle = [];
  //获取页面编号
  var PageExp = RegExp(r'<navPoint [^>]*>');
  var pageidExp = RegExp(r'(?<=playOrder=").*?(?=")');
  if (PageExp.hasMatch(pharong)) {
    Iterable<RegExpMatch> pagmath = PageExp.allMatches(pharong);
    pagmath.forEach((element) {
      String tmppage =
          pageidExp.stringMatch(pharong.substring(element.start, element.end))!;
      phapage.add(tmppage);
      //print("页面:" + tmppage);
    });
  }
  //获取标题
  var tttExp = RegExp(r'(?<=<navLabel><text>).*(?=</text></navLabel>)');
  if (tttExp.hasMatch(pharong)) {
    print("yes");
    Iterable<RegExpMatch> tmath = tttExp.allMatches(pharong);
    tmath.forEach((element) {
      String pagetitle = pharong.substring(element.start, element.end);
      phatitle.add(pagetitle);
      //print(pagetitle);
    });
    /*
    Iterable<RegExpMatch> titmath = tttExp.allMatches(pharong);
    titmath.forEach((element) {
      String tttpage =
          pageidExp.stringMatch(pharong.substring(element.start, element.end))!;
      print("标题:" + tttpage);
    });

     */
  }

  //获取书名
  var TitleExp = RegExp(r'(?<=<dc:title>).*(?=<\/dc:title>)');
  if (TitleExp.hasMatch(neirong)) {
    title = TitleExp.stringMatch(neirong)!;
  }
  print("标题是" + title.toString());
  //获取作者信息
  var AutorExp = RegExp(r'(?<=<dc:creator>).*(?=<\/dc:creator>)');
  if (AutorExp.hasMatch(neirong)) {
    author = AutorExp.stringMatch(neirong)!;
  }
  print("作者" + author.toString());
  //获取版权信息
  var RightExp = RegExp(r'(?<=<dc:rights>).*(?=<\/dc:rights>)');
  if (RightExp.hasMatch(neirong)) {
    right = RightExp.stringMatch(neirong)!;
  }
  print("版权" + right.toString());
  //获取日期
  var DateExp = RegExp(r'(?<=<dc:date>).*(?=<\/dc:date>)');
  if (DateExp.hasMatch(neirong)) {
    date = DateExp.stringMatch(neirong)!;
  }
  print("日期" + date.toString());
  //获取系列
  var SerExp = RegExp(r'(?<=<dc:series>).*(?=<\/dc:series>)');
  if (SerExp.hasMatch(neirong)) {
    series = SerExp.stringMatch(neirong)!;
  }
  print("系列" + series.toString());
  //获取原数据结束
  Directory directory = new Directory('${tempDir.path}/epub/out');

  //开始转移图片

  List tocopyimg = json.decode(orgmap['imglist']!).cast<String>().toList();
  //print(tocopyimg.length);
  int nowitem = 0;
  tocopyimg.forEach((element) {
    File tmpimg = new File('${directory.path}$element');
    String exee = p.extension('${directory.path}$element');
    print('${saveDir.path}/image/$nowitem$exee');
    File createfile = new File('${saveDir.path}/image/$nowitem$exee');
    createfile.createSync();
    tmpimg.copySync('${saveDir.path}/image/$nowitem$exee');
    nowitem = nowitem + 1;
  });
  print("总页数$nowitem");
  //转移封面图片
  File coverfile = new File('${directory.path}${orgmap["coverpath"]}');
  print('${directory.path}${orgmap["coverpath"]}');
  var coverexe = p.extension('${directory.path}${orgmap["coverpath"]}');
  File createfile = new File('${saveDir.path}/cover$coverexe');
  createfile.createSync();
  coverfile.copySync('${saveDir.path}/cover$coverexe');
  //转移创作图片

  Map<String, dynamic> mangameta = {
    "id": uid,
    "title": title,
    "author": author,
    "right": right,
    "date": date,
    'series': series,
    "cover": 'cover$coverexe',
    'pages': nowitem,
    'phapage': json.encode(phapage),
    'phatitle': json.encode(phatitle),
  };
  String finalsave = json.encode(mangameta);
  File finalcreate = new File('${saveDir.path}/meta.json');
  finalcreate.createSync();
  finalcreate.writeAsStringSync(finalsave);
  //数据库保存
  Map<String, Object?> mangamaps = {
    'uid': uid,
    'title': title,
    'cover': 'cover$coverexe',
    'author': author,
  };
  insertsql(mangamaps);
  print("任务结束");
  return "ok";
}

Future<String> getsingleimg(String htmlpath) async {
  var regExp = RegExp(r'<img src=[^>]*>');
  var imgExp = RegExp(r'(?<=src=").*?(?=")');
  late String imgpath;
  final Directory tempDir =
      await getTemporaryDirectory(); // Use an InputFileStream to access the zip file without storing it in memory.
  Directory directory = new Directory('${tempDir.path}/epub/out/');
  File htmltmp = new File('${directory.path}/$htmlpath');
  String htmlstr = htmltmp.readAsStringSync();
  if (regExp.hasMatch(htmlstr)) {
    imgpath = regExp.stringMatch(htmlstr)!;
    imgpath = imgExp.stringMatch(imgpath)!;
    imgpath = imgpath.replaceAll("../", "/");
  }
  return imgpath;
}

Future<List<String>> getimg(List<String> htmllist) async {
  print("GETTTTTTTTT");
  var regExp = RegExp(r'<img src=[^>]*>');
  var imgExp = RegExp(r'(?<=src=").*?(?=")');
  List<String> imglist = [];
  final Directory tempDir =
      await getTemporaryDirectory(); // Use an InputFileStream to access the zip file without storing it in memory.
  Directory directory = new Directory('${tempDir.path}/epub/out/');
  htmllist.forEach((element) {
    File htmltmp = new File('${directory.path}/$element');
    late String imgstr;
    String tmpstr = htmltmp.readAsStringSync();
    if (regExp.hasMatch(tmpstr)) {
      imgstr = regExp.stringMatch(tmpstr)!;
      imgstr = imgExp.stringMatch(imgstr)!;
      imgstr = imgstr.replaceAll("../", "/");
    }
    if (imgstr.contains("cover") || imgstr.contains("createby")) {
    } else {
      // print(imgstr);
      imglist.add(imgstr);
    }
  });
  return imglist;
}

Future<List<String>> getepubitem(String epubpath) async {
  var regExp = RegExp(r'<item id=[^>]*>');
  List<String> item = [];
  File metafile = File(epubpath);
  String metatxt = await metafile.readAsString();
  print(metatxt);
  Iterable<RegExpMatch> matches = regExp.allMatches(metatxt);
  matches.forEach((match) {
    //print(metatxt.substring(match.start, match.end));
    item.add(metatxt.substring(match.start, match.end));
  });
  return item;
}

Future<String> getcover(List<String> orglist) async {
  var regExp = RegExp(r'(?<=id=")Page_cover.*?html"');
  String coverpath = "1";
  orglist.forEach((element) {
    if (regExp.hasMatch(element)) {
      String? matches = regExp.stringMatch(element);
      print(matches);
      var seExp = RegExp(r'(?<=href=").*?html(?=")');
      matches = seExp.stringMatch(matches!);
      coverpath = matches!;
      print(matches);
      print("存在封面！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！");
    } else {
      //print("不存在封面！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！");
      //coverpath = "NOCOVER";
    }
  });
  //print('返回啦！！！！！！！！！！1$coverpath');
  return coverpath;
}

Future<String> getcreatby(List<String> orglist) async {
  var regExp = RegExp(r'(?<=id=")Page_createby.*?html"');
  String createby = "1";
  orglist.forEach((element) {
    if (regExp.hasMatch(element)) {
      String? matches = regExp.stringMatch(element);
      print(matches);
      var seExp = RegExp(r'(?<=href=").*?html(?=")');
      matches = seExp.stringMatch(matches!);
      createby = matches!;
      print(matches);
    } else {
      // createby = "NOCREATEBY";
    }
  });
  return createby;
}

Future<List<String>> getepubhtml(List<String> orglist) async {
  var regExp = RegExp(r'(?<=href=").*?html(?=")');
  List<String> htmlitem = [];
  orglist.forEach((element) {
    if (regExp.hasMatch(element)) {
      String? matches = regExp.stringMatch(element);
      //print(matches);
      htmlitem.add(matches!);
    }
  });
  return htmlitem;
}

String generateRandomString(int length) {
  final _random = Random();
  const _availableChars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final randomString = List.generate(length,
          (index) => _availableChars[_random.nextInt(_availableChars.length)])
      .join();

  return randomString;
}
