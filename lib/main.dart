import 'package:provider/provider.dart';
import 'package:Pedalcapp/models/Booking.dart';
import 'package:Pedalcapp/models/BookingHourly.dart';
import 'package:Pedalcapp/models/BookingCentral.dart';
import 'package:Pedalcapp/screens/pointAToB/BookingConfirmationScreen.dart';
import 'package:Pedalcapp/screens/pointAToB/PassengerDetail.dart';
import 'package:Pedalcapp/screens/hourlyServices/PassengerDetailHourly.dart';
import 'package:Pedalcapp/screens/centralParkTour/PassengerDetailCentral.dart';
import 'package:Pedalcapp/screens/pointAToB/PaymentScreen.dart';
import 'package:Pedalcapp/screens/pointAToB/ReviewDetails.dart';
import 'package:Pedalcapp/screens/pointAToB/RideInformation.dart';
import 'package:Pedalcapp/screens/hourlyServices/RideInformationHourly.dart';
import 'package:Pedalcapp/screens/hourlyServices/ReviewDetailHourly.dart';
import 'package:Pedalcapp/screens/centralParkTour/ReviewDetailCentral.dart';
import 'package:Pedalcapp/screens/hourlyServices/PaymentScreenHourly.dart';
import 'package:Pedalcapp/screens/centralParkTour/PaymentScreenCentral.dart';
import 'package:Pedalcapp/screens/hourlyServices/BookingConfirmationScreenHourly.dart';
import 'package:Pedalcapp/screens/centralParkTour/BookingConfirmationScreenCentral.dart';
import 'package:Pedalcapp/screens/centralParkTour/RideInformationCentral.dart';
import 'package:Pedalcapp/screens/SelectApp.dart';
import 'package:Pedalcapp/screens/LoginScreen.dart';
import 'package:Pedalcapp/screens/RegisterScreen.dart';
import 'package:flutter/material.dart';
import 'package:Pedalcapp/screens/SplashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      "pk_test_51JfgR1FYnXiJBvTUs62BkrJTv4PBDzEm3fCtlgKbVtMW9yECESEop3UfFxLpKU7f88EdXm9iXOHM5vBUVUIbvW8j00TcDCp4nc";
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: "assets/.env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Booking()),
        ChangeNotifierProvider(create: (context) => BookingHourly()),
        ChangeNotifierProvider(create: (context) => BookingCentral()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(fontFamily: "Poppins"),
        initialRoute: '/login',
        routes: {
          "/login": (context) => const LoginScreen(), // Login Screen
          "/register": (context) => const RegisterScreen(), // Register Screen
          "/splash": (context) => const SplashScreen(),
          "/selectApp": (context) => const SelectApp(), // Screen 1
          "/rideInformation": (context) => const RideInformation(), // Screen 2
          "/passengerDetail": (context) => const PassengerDetail(), // Screen 3
          "/reviewDetails": (context) => const ReviewDetails(), // Screen 4
          "/paymentScreen": (context) => const PaymentScreen(), // Screen 5
          "/bookingConfirmationScreen": (context) =>
              const BookingConfirmationScreen(), // Screen 5
          "/rideInformationHourly": (context) =>
              const RideInformationHourly(), // Screen 1
          "/passengerDetailHourly": (context) =>
              const PassengerDetailHourly(), // Screen 2
          "/reviewDetailsHourly": (context) =>
              const ReviewDetailsHourly(), // Screen 3
          "/paymentScreenHourly": (context) =>
              const PaymentScreenHourly(), // Screen 4
          "/BookingConfirmationScreenHourly": (context) =>
              const BookingConfirmationScreenHourly(), // Screen 5

          "/rideInformationCentral": (context) =>
              const RideInformationCentral(), // Screen 1
          "/passengerDetailCentral": (context) =>
              const PassengerDetailCentral(), // Screen 2
          "/reviewDetailsCentral": (context) =>
              const ReviewDetailsCentral(), // Screen 3
          "/paymentScreenCentral": (context) =>
              const PaymentScreenCentral(), // Screen 4
          "/BookingConfirmationScreenCentral": (context) =>
              const BookingConfirmationScreenCentral(), // Screen 5
        });
  }
}
