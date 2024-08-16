import 'package:flutter/material.dart';

class SelectApp extends StatelessWidget {
  const SelectApp({super.key});
  onPressed() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 200,
            ),
            const Text(
              'Select Your Service',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            CustomButton(
              buttonText: "Central Park Tour",
              onPressed: () {
                Navigator.pushNamed(context, '/rideInformationCentral');
              },
              icon: Icons.park,
              gradient: const LinearGradient(
                colors: [Colors.black, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              buttonText: "Point A to B Ride",
              onPressed: () {
                Navigator.pushNamed(context, '/rideInformation');
              },
              icon: Icons.directions,
              gradient: const LinearGradient(
                colors: [Colors.black, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              buttonText: "Hourly Service",
              onPressed: () {
                Navigator.pushNamed(context, '/rideInformationHourly');
              },
              icon: Icons.timer,
              gradient: const LinearGradient(
                colors: [Colors.black, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CustomButton widgetını güncellemeniz gerekebilir. İşte örnek bir CustomButton widgetı:

class CustomButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final IconData? icon;
  final Gradient? gradient;

  const CustomButton({
    required this.buttonText,
    required this.onPressed,
    this.icon,
    this.gradient,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 5,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon:
            icon != null ? Icon(icon, color: Colors.white) : SizedBox.shrink(),
        label: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
