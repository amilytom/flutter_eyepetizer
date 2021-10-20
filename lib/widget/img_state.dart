// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

class ImgState extends StatelessWidget {
  final String msg;
  final IconData icon;
  final Color errBgColor;
  ImgState({
    required this.msg,
    required this.icon,
    this.errBgColor = const Color.fromRGBO(245, 245, 245, 1),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: errBgColor,
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.black26),
            const SizedBox(height: 3),
            Text(msg, style: const TextStyle(color: Colors.black26))
          ],
        ),
      ),
    );
  }
}
