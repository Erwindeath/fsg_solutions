// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/firebase_options.dart';
import 'package:fsg_solutions/views/inicio_sesion/principal.dart';
import 'package:firebase_core/firebase_core.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var prueba = await FirebaseMessaging.instance.getToken();

  await _storage.writeSecureData("token_firebase", prueba.toString());


  runApp(const ProviderScope(child: MyApp()));
}

Colores colores = Colores();
final SecureStorage _storage = SecureStorage();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const _localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  static const _supportedLocales = [
    Locale('es', ''), // Spanish, no country code
  ];
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Asegúrate de pasar el GlobalKey aquí.

      debugShowCheckedModeBanner: false,
      localizationsDelegates: _localizationsDelegates,
      supportedLocales: _supportedLocales,
      title: 'GESTOR 360',
      locale: const Locale('es'),
      theme: ThemeData(
        primarySwatch: Colores.esquemaColor,
      ),
      home: const PrincipalLogin(),
    );
  }
}
