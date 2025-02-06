import 'package:flutter/material.dart';

class WidgetImageBar extends StatelessWidget {
  const WidgetImageBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/logoFSG.png', color: Colors.white, width: MediaQuery.of(context).size.width / 3 - 20);
  }
}
