import 'package:flutter/material.dart';
import 'package:fsg_solutions/views/administrador/validarMantenimiento/planificables/mantenimientos_planificables.dart';
import 'package:fsg_solutions/views/administrador/validarMantenimiento/urgentes/mantenimientos_emergentes.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ValidarMantenimiento extends StatefulWidget {
  
  const ValidarMantenimiento({super.key});

  @override
  State<ValidarMantenimiento> createState() => _ValidarMantenimientoState();
}

class _ValidarMantenimientoState extends State<ValidarMantenimiento> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Mantenimientos"),
            bottom: TabBar(tabs: [
              Tab(
                icon: Icon(MdiIcons.stickerAlert),
                text: "Urgentes",
              ),
              Tab(
                icon: Icon(MdiIcons.calendarAlert),
                text: "Planificables",
              ),
            ]),
          ),
          body: const TabBarView(children: [MantenimientosEmergentes(), MantenimientosPlanificables()]),
        ));
  }
}
