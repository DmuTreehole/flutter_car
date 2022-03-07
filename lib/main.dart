import 'dart:developer';
import 'dart:io';

import 'package:car/page_two.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:udp/udp.dart';
import 'joypad.dart';
import 'package:holding_gesture/holding_gesture.dart';

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
        home: const PageThree());
  }
}

class PageThree extends StatefulWidget {
  const PageThree({Key? key}) : super(key: key);

  @override
  State<PageThree> createState() => _PageThreeState();
}

class _PageThreeState extends State<PageThree> {
  @override
  void initState() {
    super.initState();
/*
    accelerometerEvents.listen((AccelerometerEvent event) {
      print(event);
    });
// [AccelerometerEvent (x: 0.0, y: 9.8, z: 0.0)]

    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      print(event);
    });
// [UserAccelerometerEvent (x: 0.0, y: 0.0, z: 0.0)]
*/
    gyroscopeEvents.listen((GyroscopeEvent event) {
      print(event);
    });
// [GyroscopeEvent (x: 0.0, y: 0.0, z: 0.0)]
/*
    magnetometerEvents.listen((MagnetometerEvent event) {
      print(event);
    });
    */
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
        ],
      ),
    );
  }
}
