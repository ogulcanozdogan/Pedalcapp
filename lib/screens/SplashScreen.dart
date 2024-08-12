import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Bu paketi pubspec.yaml'a eklemelisiniz.

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToSelectApp();
  }

  _navigateToSelectApp() async {
    await Future.delayed(const Duration(seconds: 3), () {}); // Animasyon süresi
    Navigator.pushReplacementNamed(context, '/selectApp'); // SelectApp rotası
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black, // Splash ekranınızın arka plan rengi
      body: Center(
        child: SpinKitCircle(
          color: Colors.white,
          size: 50.0,
        ),
      ),
    );
  }
}
