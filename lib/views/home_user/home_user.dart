// ignore_for_file: non_constant_identifier_names, unused_field, use_build_context_synchronously, unnecessary_null_comparison

import 'dart:collection';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsg_solutions/complementos/calendario/models/event_model.dart';
import 'package:fsg_solutions/complementos/calendario/utils/model_data.dart';
import 'package:fsg_solutions/complementos/globals/cargando.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/views/config/menu.dart';
import 'package:fsg_solutions/views/home_user/methods/faker_api.dart';
import 'package:fsg_solutions/views/inicio_sesion/providers/push_notification.dart';
import 'package:intl/intl.dart';
import 'package:fsg_solutions/complementos/calendario/utils/utils.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/views/home_user/methods/get_ubicacion.dart';
import 'package:fsg_solutions/views/home_user/methods/utils.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:upgrader/upgrader.dart';

import '../inicio_sesion/providers/provider/providers.dart';

class HomeUser extends ConsumerStatefulWidget {
  const HomeUser({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeUserState();
}

class _HomeUserState extends ConsumerState<HomeUser> {
  final List<Data> _allEvents = [];
  bool load = false;
  bool cargando = false;
  List<Widget> WFarmacia = [];
  List<Map<String, dynamic>> Farmacias_Listado = [];
  Map<String, List<Data>> eventsByDate = {};
  DateTime? _lastLocationDate;
  LocationData? _lastLocationData;
  List<AppEvent> events = [];
  DateTime now = DateTime.now();
  CalendarFormat formato = CalendarFormat.twoWeeks;
  String codPerfil = "";
  String _lon = "0.0";
  String _lat = "0.0";
  String _geohash = "0";

  DateTime? _selectedDay;
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();
  LinkedHashMap<DateTime, List<AppEvent>>? _groupedEvents;
  final SecureStorage _storage = SecureStorage();
  String token = "";

  late SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const MenuUsuario(),
      appBar: AppBar(
        title: Image.asset('assets/images/logoFSG.png', color: Colors.white, width: MediaQuery.of(context).size.width / 3 - 20),
        actions: [
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    iniciarSesionNormal(context);
                  },
                  icon: const Icon(
                    Icons.admin_panel_settings,
                    size: 30.0,
                  )),
              Builder(
                  builder: (context) => IconButton(
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                        icon: const Icon(Icons.account_circle),
                        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                      )),
            ],
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          obtenerDatosIniciales(ref);
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [codPerfil == "9" ? calendarioSupervisor(context) : calendario(context, ref), Expanded(child: datos(ref))],
            ),
          ),
        ),
      ),
      /* floatingActionButton: codPerfil == "9"
            ? FloatingActionButton(
                onPressed: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return LoginBodega(
                      longitud: _lon,
                      latitud: _lat,
                      comprueba: 2,
                    );
                  }));
                },
                child: const Icon(Icons.groups),
              )
            : null*/
    );
  }

  @override
  void initState() {
    super.initState();
    validaInicio();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        obtenerDatosIniciales(ref);
      }
    });
  }

  Widget datos(WidgetRef ref) {
    final wFarmacias = ref.watch(wFarmaciaProvider);

    if (!load) {
      return const CircularPrimero(texto: "Cargando planificación....");
    } else if (!ref.watch(cargandoProvider)) {
      return const CircularPrimero(texto: "Cargando datos....");
    } else {
      return generarFarmacias(wFarmacias, context, _lon, _lat);
    }
  }

  Widget calendario(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Card(
        elevation: 2,
        child: TableCalendar(
          onDaySelected: (selectedDay, focusedDay) {
            _onDaySelected(selectedDay, focusedDay, this.ref);
          },
          focusedDay: now,
          firstDay: kFirstDay,
          lastDay: kLastDay,
          calendarFormat: formato,
          startingDayOfWeek: StartingDayOfWeek.monday,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: _getEventsForDay,
          onPageChanged: (focusedDay) {
            now = focusedDay;
          },
          onFormatChanged: (CalendarFormat format) {
            setState(() {
              formato = format;
            });
          },
          availableCalendarFormats: const {CalendarFormat.month: 'Mes', CalendarFormat.week: 'Semana', CalendarFormat.twoWeeks: '2 semanas'},
          locale: 'es_ES',
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
          ),
          calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(color: Color(0xff62242C), shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              if (events.isNotEmpty) {
                return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                      bottom: 2.0,
                      child: Container(
                        height: 10.0,
                        width: 10.0,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget calendarioSupervisor(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Card(
        elevation: 2,
        child: TableCalendar(
          onDaySelected: (selectedDay, focusedDay) {
            _onDaySelected(selectedDay, focusedDay, ref);
          },
          focusedDay: now,
          firstDay: kFirstDay,
          lastDay: kLastDay,
          calendarFormat: formato,
          startingDayOfWeek: StartingDayOfWeek.monday,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: _getEventsForDay,
          onPageChanged: (focusedDay) {
            now = focusedDay;
          },
          onFormatChanged: (CalendarFormat format) {
            setState(() {
              formato = format;
            });
          },
          availableCalendarFormats: const {CalendarFormat.month: 'Mes', CalendarFormat.week: 'Semana', CalendarFormat.twoWeeks: '2 semanas'},
          locale: 'es_ES',
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
          ),
          calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(color: Color(0xff62242C), shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              if (events.isNotEmpty) {
                return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                      bottom: 2.0,
                      child: Container(
                        height: 10.0,
                        width: 10.0,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Future<void> validaInicio() async {
    codPerfil = await _storage.readSecureData("cod_perfil") ?? "";
  }

  Future<void> obtenerDatosIniciales(WidgetRef ref) async {
    Farmacias_Listado.clear();

    var codUsuario = await _storage.readSecureData("cod_usuario");

    token = await _storage.readSecureData("token");
    ref.read(wFarmaciaProvider.notifier).actualizarListaFarmacias([]);

    addSchedules(int.parse(codUsuario));
    PushNotification pushNotification = PushNotification();
    await pushNotification.initializeApp();
    WidgetsFlutterBinding.ensureInitialized();
    await Upgrader.clearSavedSettings();
    var retorno = await conseguirUbicacion();

    if (retorno["estado"] == "false") return;
    String longActual = retorno["longitude"] ?? "0.0";
    String latActual = retorno["latitude"] ?? "0.0";
    String geohash_ = await conseguirGeoHash(double.parse(longActual), double.parse(latActual));
    DateTime now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);

    Farmacias_Listado = _allEvents
        .where((event) => event.Fecha_Inicio.startsWith(formattedDate))
        .map((event) => {
              'codInventario': event.codInventario,
              'Fecha_Inicio': event.Fecha_Inicio,
              'Nombre': event.Nombre,
              'codBodega': event.codBodega,
              'Ciudad': event.Ciudad,
              'long': event.long,
              'lat': event.lat,
              'Ubicacion': event.ubicacion,
              'LlaveQR': event.LlaveQR,
              'metodo':event.metodo
            })
        .toList();
    if (Farmacias_Listado.isEmpty) {
      ref.read(cargandoProvider.notifier).cambiarEstado();

      setState(() {
        // cargando = true;
        _lon = longActual;
        _lat = latActual;
      });
      WFarmacia = [];
      if (codPerfil != "9") {
        ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "Error al cargar!",
                confirmButtonText: "Aceptar",
                text: "No tiene inventarios asignados para esta fecha",
                confirmButtonColor: Colores.esquemaColor));
      } else {
        ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "Error al cargar!",
                confirmButtonText: "Aceptar",
                text: "No tiene planificaciones para esta fecha",
                confirmButtonColor: Colores.esquemaColor));
      }
      return;
    }
    for (var value in Farmacias_Listado) {
      double longFarmacia = double.parse(value["long"].toString());
      double latFarmacia = double.parse(value["lat"].toString());

      value["geohash"] = await conseguirGeoHash(longFarmacia, latFarmacia);
      value["distancia"] = calcularDistanciaEnKm(latFarmacia, longFarmacia, double.parse(latActual), double.parse(longActual));
    }

    actualizarListaFarmacias(Farmacias_Listado, longActual, latActual, ref);
    if (!ref.watch(cargandoProvider)) {
      ref.read(cargandoProvider.notifier).cambiarEstado();
    }
    setState(() {
      // cargando = true;
      _lon = longActual;
      _lat = latActual;
      _geohash = geohash_;
    });
  }

  Future addSchedules(int codUsuario) async {
    events.clear();
    _allEvents.clear();
    try {
      var schedules = await FakerApi.getData(token, codUsuario);
      // Verificar si schedules es nulo antes de procesarlo
      if (schedules != null && schedules.isNotEmpty) {
        for (var schedule in schedules) {
          events.add(AppEvent(
            date: DateTime.parse(schedule.Fecha_Inicio),
          ));
          _allEvents.add(Data(
              codInventario: schedule.codInventario,
              Fecha_Inicio: schedule.Fecha_Inicio,
              Nombre: schedule.Nombre,
              codBodega: schedule.codBodega,
              Ciudad: schedule.Ciudad,
              long: schedule.long ?? 0.0,
              lat: schedule.lat ?? 0.0,
              ubicacion: schedule.ubicacion,
              LlaveQR: schedule.LlaveQR,
              metodo: schedule.metodo));
        }
        if (!ref.watch(cargandoProvider)) {
          ref.read(cargandoProvider.notifier).cambiarEstado();
        }
        groupEventsByDate();
      } else {
        setState(() {
          load = true;
        });
      }
    } catch (e) {
      ArtSweetAlert.show(
          barrierDismissible: false,
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "Error al cargar!",
              confirmButtonText: "Aceptar",
              text: e.toString(),
              confirmButtonColor: Colores.esquemaColor));
    } finally {
      setState(() {
        load = true;
      });
    }
    _groupEvents(events);
  }

  List<dynamic> _getEventsForDay(DateTime date) {
    if (_groupedEvents != null) {
      return _groupedEvents![date] ?? [];
    }
    return [];
  }

  _groupEvents(List<AppEvent> events) {
    _groupedEvents = LinkedHashMap(equals: isSameDay, hashCode: getHashCode);
    for (var event in events) {
      DateTime date = DateTime.utc(event.date!.year, event.date!.month, event.date!.day, 12);
      if (_groupedEvents![date] == null) _groupedEvents![date] = [];
      _groupedEvents![date]!.add(event);
    }
  }

  void groupEventsByDate() {
    eventsByDate.clear();
    for (var event in _allEvents) {
      String date = DateFormat('yyyy-MM-dd').format(DateTime.parse(event.Fecha_Inicio));
      if (eventsByDate[date] == null) {
        eventsByDate[date] = [];
      }
      eventsByDate[date]!.add(event);
    }
  }

  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay, WidgetRef ref) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDay);

    List<Data>? eventsForSelectedDate = eventsByDate[formattedDate];

    if (eventsForSelectedDate == null || eventsForSelectedDate.isEmpty) {
      /*setState(() {
        WFarmacia = [];
      });*/

      ref.read(cargandoProvider.notifier).cambiarEstado(); // Cambia el estado usando el provider
      ref.read(wFarmaciaProvider.notifier).actualizarListaFarmacias([]); // Vacía la lista usando el provider

      if (codPerfil != "9") {
        ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "Error al cargar!",
                confirmButtonText: "Aceptar",
                text: "No tiene inventarios asignados para esta fecha",
                confirmButtonColor: Colores.esquemaColor));
      } else {
        ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "Error al cargar!",
                confirmButtonText: "Aceptar",
                text: "No tiene planificaciones para esta fecha",
                confirmButtonColor: Colores.esquemaColor));
      }
      ref.read(cargandoProvider.notifier).cambiarEstado(); // Cambia el estado usando el provider
      return;
    }

    //ref.read(cargandoProvider.notifier).cambiarEstado(); // Cambia el estado usando el provider

    LocationData locationData;
    if (_lastLocationDate != null && DateFormat('yyyy-MM-dd').format(_lastLocationDate!) == formattedDate) {
      locationData = _lastLocationData!;
    } else {
      var retorno = await conseguirUbicacion();
      if (retorno["estado"] == "false") return;
      locationData = LocationData.fromMap({
        'latitude': double.parse(retorno["latitude"]!),
        'longitude': double.parse(retorno["longitude"]!),
      });
      _lastLocationDate = selectedDay;
      _lastLocationData = locationData;
    }

    double longActual = locationData.longitude!;
    double latActual = locationData.latitude!;

    Farmacias_Listado = eventsForSelectedDate
        .map((event) => {
              'codInventario': event.codInventario,
              'Fecha_Inicio': event.Fecha_Inicio,
              'Nombre': event.Nombre,
              'codBodega': event.codBodega,
              'Ciudad': event.Ciudad,
              'long': event.long,
              'lat': event.lat,
              'Ubicacion': event.ubicacion,
              'LlaveQR': event.LlaveQR,
              'metodo':event.metodo
            })
        .toList();

    for (var value in Farmacias_Listado) {
      double longFarmacia = double.parse(value["long"].toString());
      double latFarmacia = double.parse(value["lat"].toString());

      value["geohash"] = await conseguirGeoHash(longFarmacia, latFarmacia);
      value["distancia"] = calcularDistanciaEnKm(latFarmacia, longFarmacia, latActual, longActual);
    }

    String geohash = await conseguirGeoHash(longActual, latActual);
    if (ref.watch(cargandoProvider)) {
      ref.read(wFarmaciaProvider.notifier).actualizarListaFarmacias([]);
    }
    actualizarListaFarmacias(Farmacias_Listado, longActual.toString(), latActual.toString(), ref);
    if (!ref.watch(cargandoProvider)) {
      ref.read(cargandoProvider.notifier).cambiarEstado();
    }

    setState(() {
      _selectedDay = selectedDay;
      now = focusedDay;
      _lon = longActual.toString();
      _lat = latActual.toString();
      _geohash = geohash;
    });
  }

  void actualizarListaFarmacias(List<Map<String, dynamic>> valor, String latitud, String longitud, WidgetRef ref) {
    // Solo actualiza el estado del proveedor, no necesitas generar los widgets aquí
    ref.read(wFarmaciaProvider.notifier).actualizarListaFarmacias(valor);
  }
}
