// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/views/home_farma/home_farma.dart';
import 'package:fsg_solutions/views/home_user/home_user.dart';
import 'package:fsg_solutions/views/inicio_sesion/login.dart';
import 'package:fsg_solutions/views/supervisores/menuSuper.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PrincipalLogin extends StatefulWidget {
  const PrincipalLogin({
    Key? key,
  }) : super(key: key);

  @override
  State<PrincipalLogin> createState() => _PrincipalLoginState();
}

class _PrincipalLoginState extends State<PrincipalLogin> {
  final SecureStorage _storage = SecureStorage();
  String loginVerification = "";
  String loginBodega = "";
  int codPerfil = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loginVerification != ""
          ? (codPerfil == 9 || codPerfil == 42 ? const MenuSuper() : (loginBodega != "" ? const HomeFarma() : const HomeUser()))
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/logoRound.png",
                          fit: BoxFit.contain,
                          height: 100.0,
                          width: 100.0,
                        ),
                        const SizedBox(width: 20),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "GESTOR 360",
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                color: Color(0xff571E25),
                                fontWeight: FontWeight.bold,
                                fontSize: 25.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          foregroundColor: MaterialStateProperty.all<Color>(Colores.esquemaColor)),
                      onPressed: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return const Login();
                        }));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: [
                            Icon(MdiIcons.medicalBag),
                            const SizedBox(width: 10),
                            const Text("Empezar"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
      /*  ],
      ),*/
    );
  }

  @override
  void initState() {
    super.initState();
    checkCredentials();
  }

  Future<void> checkCredentials() async {
    try {
      String data = await _storage.readSecureData("token") ?? "";
      String dataPerfil = await _storage.readSecureData("cod_perfil") ?? "";
      String dataBodega = await _storage.readSecureData("LoginBodega") ?? "";

      setState(() {
        codPerfil = int.parse(dataPerfil.trim());
        loginVerification = data;
        loginBodega = dataBodega;
      });
    } catch (e) {
      print(e);
    }
  }
}
