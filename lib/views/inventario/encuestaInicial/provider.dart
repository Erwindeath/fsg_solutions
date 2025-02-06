import 'package:flutter_riverpod/flutter_riverpod.dart';

final obteniendoDatos = StateProvider<bool>((ref) => false);

final enviando = StateProvider<bool>((ref) => true);