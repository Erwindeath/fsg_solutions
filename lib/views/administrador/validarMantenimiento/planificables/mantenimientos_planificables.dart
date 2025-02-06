import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:upgrader/upgrader.dart';

import '../../../../complementos/globals/cargando.dart';
import '../../../../complementos/globals/colors.dart';
import '../../../../complementos/globals/manteni_tarjeta.dart';
import '../../../../complementos/logica/storage.dart';
import '../providers/mantenimientos_providers.dart';
import '../clase_mantenimientos.dart';
import '../urgentes/logica.dart';
import '../urgentes/methods.dart';

class MantenimientosPlanificables extends ConsumerStatefulWidget {
  const MantenimientosPlanificables({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MantenimientosPlanificablesState();
}

class _MantenimientosPlanificablesState extends ConsumerState<MantenimientosPlanificables> {
  String token = "";
  SecureStorage storage = SecureStorage();
  List<Mantenimientos> mantenimientos = [];
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      child: RefreshIndicator(
          child: Column(
            children: [const SizedBox(height: 5), datos(ref)],
          ),
          onRefresh: () async {
            obtenerDatosIniciales(ref);
          }),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        obtenerDatosIniciales(ref);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget datos(WidgetRef ref) {
    if (!ref.watch(cargandoProvider)) {
      return const CircularPrimero(
        texto: "Cargando mantenimientos planificables...",
      );
    } else if (!ref.watch(cargadoProvider)) {
      return const Center(child: Text("Sin datos"));
    } else {
      return tarjeta(ref);
    }
  }

  Future<void> obtenerDatosIniciales(WidgetRef ref) async {
    token = await storage.readSecureData("token");
    if (!mounted) return;
    ref.read(cargadoProvider.notifier).state = false;
    ref.read(cargandoProvider.notifier).state = false;
    try {
      var datos = await obtenerMantenimientosPlanificables(token);
      var mensaje = jsonDecode(datos.body);
      if (mensaje["msg"] != "err") {
        var mantenimientos = convertirDatosARutasConMantenimientos(datos.body);

        ref.read(mantenimientosProvider.notifier).actualizarMantenimientos(mantenimientos);
        ref.read(cargandoProvider.notifier).cambiarEstado();
        ref.read(cargadoProvider.notifier).cambiarEstado();
      } else {
        ref.read(cargandoProvider.notifier).cambiarEstado();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ArtSweetAlert.show(
                barrierDismissible: false,
                context: context,
                artDialogArgs: ArtDialogArgs(
                    type: ArtSweetAlertType.success,
                    title: "Sin mantenimientos",
                    text: "No tiene mantenimientos planificables pendientes",
                    confirmButtonText: "Aceptar",
                    onConfirm: () async {
                      Navigator.pop(context);
                    },
                    confirmButtonColor: Colores.esquemaColor));
          }
        });
      }
    } catch (e) {
      ref.read(cargandoProvider.notifier).cambiarEstado();
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: e.toString(),
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  Widget tarjeta(WidgetRef ref) {
    final mantenimientos = ref.watch(mantenimientosProvider);

    return Expanded(
      child: ListView.builder(
        itemCount: mantenimientos.length,
        itemBuilder: (context, index) {
          final mantenimiento = mantenimientos[index];
          return Tarjeta(
            rutaConMantenimientos: mantenimiento,
            onTap: () {},
            validacion: false,
            onFechaSeleccionada: () => obtenerDatosIniciales(ref),
          );
        },
      ),
    );
  }
}
