
import 'dart:developer';
import 'dart:io';

import 'package:car/joypad.dart';
import 'package:flutter/material.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:udp/udp.dart';

class PageTwo extends StatefulWidget {
  const PageTwo({Key? key}) : super(key: key);

  @override
  State<PageTwo> createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
  var tip = "无操作";
  var speed = 400;
  var serport = 7895;
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

// 长按提速降速
  _speedbtn(IconData icon, Function fn) {
    return HoldDetector(
        onHold: () => fn(),
        holdTimeout: const Duration(milliseconds: 10),
        enableHapticFeedback: true,
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
              if (speed % 50 == 0) {
                _send("speedup\n");
              }
              setState(() {
                speed++;
              });
            }),
            SizedBox(height: size.height * 0.1),
            _speedbtn(Icons.arrow_downward_rounded, () {
              if (speed == 0) return; // 最低为0
              if (speed % 50 == 0) {
                _send("speeddown\n");
              }
              setState(() {
                speed--;
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
      tip = mes;
      speed = v;
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