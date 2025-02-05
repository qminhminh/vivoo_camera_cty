import 'package:flutter/material.dart';
import 'package:vivoo_camera_cty/constants/constants.dart';

class NoConnectpage extends StatefulWidget {
  const NoConnectpage({super.key});

  @override
  State<NoConnectpage> createState() => _NoConnectpageState();
}

class _NoConnectpageState extends State<NoConnectpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: Center(
        child: Image.asset(
          'assets/images/wifi.jpg',
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
      ),
    );
  }
}
