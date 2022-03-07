import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:udp/udp.dart';
import 'joypad.dart';
//import 'package:holding_gesture/holding_gesture.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置屏幕方向(设置屏幕方向为横向)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // 禁止所有UI层(设置全屏)
  if (Platform.isAndroid) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Car demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const PageTwo());
  }
}

class PageTwo extends StatefulWidget {
  const PageTwo({Key? key}) : super(key: key);

  @override
  State<PageTwo> createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
  var tip = "无操作";
  var speed = 400;
  var serport = 7895;
  var speedchange = 0;
  _show(Size size, var text) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular((20))),
        width: size.width * 0.3,
        height: size.height * 0.1,
        child: Center(
            child: Text(
          text.toString(),
          style: const TextStyle(
              fontSize: 25, decoration: TextDecoration.none), // 取消下划线
        )));
  }

// 点按提速降速
  _speedbtn(IconData icon, Function fn) {
    return GestureDetector(
        onLongPress: () => fn(),
        onTapCancel: () => {
              speed = 400,
              speedchange = 0,
            },
        child: Container(
          width: 80,
          height: 100,
          decoration: BoxDecoration(
              color: const Color(0x88ffffff),
              borderRadius: BorderRadius.circular((20))),
          child: Icon(
            icon,
            size: 50,
          ),
        ));
  }

  Padding _content(Size size) {
    return Padding(
      // 上下位置
      padding: EdgeInsets.only(top: size.height * 0.05),
      // 主要结构
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 显示区
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 平均分布
            children: [
              _show(size, speed),
              _show(size, tip),
            ],
          ),
          SizedBox(
            height: size.height * 0.14,
          ),
          // 按钮层
          _padbtn(size),
        ],
      ),
    );
  }

  Row _padbtn(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 摇杆
        Joypad(
          onChange: (Offset delta) {
            _onchange(delta);
          },
        ),
        _speedbtn(Icons.stop_circle, () {
          _send("stop\n");
          setState(() {
            speed = 0;
            tip = "stop";
          });
        }),

        // 速度按钮
        Column(
          children: [
            _speedbtn(Icons.arrow_upward_rounded, () {
              _send("speedup\n");
              setState(() {
                speedchange = 1;
              });
            }),
            SizedBox(height: size.height * 0.1),
            _speedbtn(Icons.arrow_downward_rounded, () {
              _send("speeddown\n");
              setState(() {
                speedchange = 2;
              });
            })
          ],
        )
      ],
    );
  }

  _onchange(Offset delta) {
    //log(delta.toString());
    var x = delta.dx;
    var y = delta.dy;
    var mes = "";
    var v = 400;
    if (x == 0 && y == 0) {
      mes = "stop";
      v = 0;
    } else if (y < -15.0) {
      log("up");
      mes = "up";
      v = 400;
    } else if (y > 15.0) {
      log("back");
      mes = "back";
      v = 400;
    } else if (y > -15.0 && x < 0) {
      log("left");
      mes = "left";
      v = 400;
    } else if (y > -15.0 && x > 0) {
      log("right");
      v = 400;
      mes = "right";
    }

    _send(mes + '\n');
    setState(() {
      if (speedchange == 1) {
        tip = 'speedup';
        speed = 800;
      } else if (speedchange == 2) {
        tip = 'speeddown';
        speed = 200;
      } else {
        tip = mes;
        speed = v;
      }
    });
  }

  // 发送请求
  _send(String buf) async {
    var sender = await UDP.bind(Endpoint.any());
    var dataLength = await sender.send(buf.codeUnits,
        Endpoint.unicast(InternetAddress('192.168.1.1'), port: Port(serport)));
    log("$dataLength bytes sent.");
    sender.close();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Directionality(
      textDirection: TextDirection.ltr, //文本方向
      child: Stack(
        children: [
          // 为游戏提供占位符
          Container(
            color: Colors.blueGrey,
          ),
          // 摇杆层
          _content(size)
        ],
      ),
    );
  }
}
