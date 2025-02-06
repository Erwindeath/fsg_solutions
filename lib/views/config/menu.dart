import 'package:flutter/material.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/views/inicio_sesion/models/logica_login.dart';
import 'package:fsg_solutions/views/inicio_sesion/principal.dart';

class MenuUsuario extends StatefulWidget {
  const MenuUsuario({Key? key}) : super(key: key);

  @override
  State<MenuUsuario> createState() => _MenuUsuarioState();
}

class _MenuUsuarioState extends State<MenuUsuario> {
  //TabController? _tabController;
  final FocusNode myFocusNode = FocusNode();
  final SecureStorage _storage = SecureStorage();
  String _nombre = "";
  String _cargo = "";
  TextEditingController name = TextEditingController();
  TextEditingController cargo = TextEditingController();
  @override
  void initState() {
    datosUsuario();
    super.initState();
  }

  Future<void> goToHome() async {
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) => const PrincipalLogin(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  Widget cerrarSession() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 45.0,
      padding: const EdgeInsets.symmetric(horizontal: 1.0),
      margin: const EdgeInsets.only(top: 10.0),
      child: ElevatedButton(
        onPressed: () async {
          var logoutCheck = await logout();
          if (logoutCheck) {
            await goToHome();
          }
        },
        style: ElevatedButton.styleFrom(
            disabledBackgroundColor: const Color.fromARGB(255, 69, 83, 206),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0))),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Cerrar Sesión",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.logout,
                size: 20.0,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: imagen(),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xff97696F).withOpacity(0.10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 1.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 25.0),
                            child: dataUsuario("información personal", 18.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 25.0),
                            child: dataUsuario("Nombre", 16.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 25.0),
                            child: pDataUsuario(_nombre, 12.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 25.0),
                            child: dataUsuario("Cargo", 16.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 25.0),
                            child: pDataUsuario(_cargo, 12.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: cerrarSession(),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void datosUsuario() async {
    //final info= await Printing.info();

    var nombre = await _storage.readSecureData("Nombre");
    var cargo = await _storage.readSecureData("Cargo");
    setState(() {
      _nombre = nombre;
      _cargo = cargo;
    });
  }

  Widget imagen() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(255, 255, 245, 245),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 230, 228, 228),
            offset: Offset(10, 20),
            blurRadius: 30,
          )
        ],
      ),
      height: 250.0,
      child: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(left: 20.0, top: 20.0),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Stack(fit: StackFit.loose, children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height / 4,
                      decoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/logo.png'),
                          fit: BoxFit.fill,
                        ),
                      )),
                ],
              ),
            ]),
          )
        ],
      ),
    );
  }

  Widget dataUsuario(String texto, double fontSize) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              texto,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget pDataUsuario(String texto, double fontSize) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Flexible(
          child: Text(
            texto,
            style: TextStyle(
              decoration: TextDecoration.none,
              color: const Color(0xff804850),
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}
