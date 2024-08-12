import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String subtitle;

  const Header({Key? key, this.subtitle = "Point A to B Pedicab Ride"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text("Pedalcapp",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 1),
                  fontSize: 30,
                  fontWeight: FontWeight.bold)),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 1),
                  fontSize: 24,
                  fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}
