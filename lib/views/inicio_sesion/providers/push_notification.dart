// ignore_for_file: depend_on_referenced_packages, unused_field

import 'dart:async';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/firebase_options.dart';
import 'package:fsg_solutions/main.dart';

class PushNotification {
  static int _notificationId = 0;
  static String? prueba;
  final SecureStorage _storage = SecureStorage();
  static final StreamController<String> _messagecontroller = StreamController.broadcast();

  static Stream<String> get messagStream => _messagecontroller.stream;

  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static Future _background(RemoteMessage message) async {
    await Firebase.initializeApp();
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var bigTextStyleInformation = BigTextStyleInformation(
      message.data['body'],
      htmlFormatBigText: true,
      htmlFormatContent: true,
    );
    var androidPlatformChannel = AndroidNotificationDetails("ec.fsg.notifysound_externo", "Farmacia San Gregorio",
        sound: const RawResourceAndroidNotificationSound('sangrego'),
        playSound: true,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: bigTextStyleInformation,
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'));
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannel);
    await flutterLocalNotificationsPlugin.show(
      _notificationId++,
      message.data['title'],
      message.data['body'],
      platformChannelSpecifics,
      payload: '',
    );
  }

  static Future _onMessage(RemoteMessage message) async {
    await Firebase.initializeApp();
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var bigTextStyleInformation = BigTextStyleInformation(
      message.data['body'],
      htmlFormatBigText: true,
      htmlFormatContent: true,
    );
    var androidPlatformChannel = AndroidNotificationDetails("ec.fsg.notifysound_externo", "Farmacia San Gregorio",
        sound: const RawResourceAndroidNotificationSound('sangrego'),
        playSound: true,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: bigTextStyleInformation,
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'));
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannel);
    if (navigatorKey.currentState != null) {
      ArtSweetAlert.show(
          barrierDismissible: false,
          context: navigatorKey.currentContext!,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.warning,
              title: message.data['title'],
              text: message.data['body'],
              confirmButtonText: "Aceptar",
              onConfirm: () async {
                Navigator.pop(navigatorKey.currentContext!);
              },
              cancelButtonColor: Colors.grey,
              confirmButtonColor: Colores.esquemaColor));
    }

    await flutterLocalNotificationsPlugin.show(
      _notificationId++,
      // message.notification.hashCode,
      message.data['title'],
      message.data['body'],
      platformChannelSpecifics,
      payload: '',
    );

  //print("Message: ${message.data}");
    _messagecontroller.add(message.notification?.title ?? 'Sin datos');
  }

  static Future _onOpenAppMessage(RemoteMessage message) async {
    await Firebase.initializeApp();
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    var bigTextStyleInformation = BigTextStyleInformation(
      message.data['body'],
      htmlFormatBigText: true,
      htmlFormatContent: true,
    );
    var androidPlatformChannel = AndroidNotificationDetails("ec.fsg.notifysound_externo", "Farmacia San Gregorio Bodega",
        sound: const RawResourceAndroidNotificationSound('sangrego'),
        playSound: true,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: bigTextStyleInformation,
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'));
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannel);
    await flutterLocalNotificationsPlugin.show(
      _notificationId++,
      message.data['title'],
      message.data['body'],
      platformChannelSpecifics,
      payload: '',
    );
  }

  Future initializeApp() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((value) async {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, // Required to display a heads up notification
        badge: true,
        sound: true,
      );
      FirebaseMessaging.onBackgroundMessage(_background);
      FirebaseMessaging.onMessage.listen(_onMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onOpenAppMessage);
    });
  }

  static closeStreams() {
    _messagecontroller.close();
  }
}
