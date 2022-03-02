import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:udp/udp.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MainPage());
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String ip = "";
  String tip = "无设备";
  final clientport = 7896;
  final serport = 7895;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        color: Colors.blueGrey,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: size.height * 0.1,
            ),
            // _text(),
            _show(size),
            SizedBox(
              height: size.height * 0.1,
            ),
            _movewidget()
          ],
        ),
      ),
    );
  }

  // 指示
  _show(Size size) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular((40))),
        width: size.width * 0.7,
        height: size.height * 0.3,
        child: Center(
            child: Text(
          tip,
          style: const TextStyle(fontSize: 30),
        )));
  }

  //移动函数
  _move(Function fn, IconData icon) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular((180))),
        child: IconButton(onPressed: () => fn(), icon: Icon(icon)));
  }

  _fn(String buf) {
    _send(buf);
    setState(() {
      tip = buf;
    });
  }

  // 发送请求
  _send(String buf) async {
    var sender = await UDP.bind(Endpoint.any());
    var dataLength = await sender.send(
        buf.codeUnits, Endpoint.broadcast(port: Port(serport)));
    log("$dataLength bytes sent.");
    sender.close();
  }

  // 移动函数布局
  _movewidget() {
    return Column(
      children: <Widget>[
        // 向上
        _move(() => _fn("up\n"), Icons.keyboard_arrow_up_sharp), //加入结束符 否则服务端不显示
        // 左右
        Container(
          margin: const EdgeInsets.symmetric(vertical: 70),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _move(() => _fn("left\n"), Icons.arrow_back_ios_new_sharp),
              _move(() => _fn("right\n"), Icons.arrow_forward_ios_sharp), 
            ],
          ),
        ),
        // 向下
        _move(() => _fn("back\n"), Icons.keyboard_arrow_down_sharp),
      ],
    );
  }
}
