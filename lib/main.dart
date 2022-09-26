import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:medicine/screen/member_home_screen.dart';
import 'package:medicine/screen/splash_screen.dart';

void main() async {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  await AndroidAlarmManager.initialize();
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    if (message.data["title"] != null) {
      Navigator.push(
          navigatorKey.currentState!.context,
          MaterialPageRoute(
              builder: (context) =>
                  MemberHomeScreen(remoteData: message.data["title"])));
    }
  });

  runApp(
    MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
