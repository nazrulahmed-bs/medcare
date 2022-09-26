import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }
  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> initNotification(
      void Function(String?)? onSelectNotification) async {
    // Android initialization
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // ios initialization
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    // the initialization settings are initialized after they are setted
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future<void> showNotification(int id, String title, String body, image,
      String payload, TimeOfDay selectedTime) async {
    final currentDate = DateTime.now();
    final String bigPicturePath =
        await _downloadAndSaveFile(image, 'bigPicture');

    tz.initializeTimeZones();
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        title,
        body,
        tz.TZDateTime.from(
                DateTime(currentDate.year, currentDate.month, currentDate.day,
                    selectedTime.hour, selectedTime.minute),
                tz.local)
            .add(Duration(days: 1)),
        NotificationDetails(
          // Android details
          android: AndroidNotificationDetails(
            'main_channel',
            'Main Channel',
            channelDescription: "medicine_reminder",
            importance: Importance.max,
            priority: Priority.max,
            fullScreenIntent: true,
            autoCancel: false,
            sound: RawResourceAndroidNotificationSound('ring'),
            playSound: true,
            styleInformation: BigPictureStyleInformation(
                FilePathAndroidBitmap(bigPicturePath),
                contentTitle: title,
                htmlFormatContentTitle: true,
                summaryText: body,
                htmlFormatSummaryText: true),
          ),
          // iOS details
          iOS: IOSNotificationDetails(
            sound: 'default.wav',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidAllowWhileIdle: true,
        payload: payload);
  }
}
