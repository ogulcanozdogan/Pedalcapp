import 'package:Pedalcapp/models/BookingHourly.dart';
import 'package:Pedalcapp/widgets/CustomButton.dart';
import 'package:Pedalcapp/widgets/FeeDetail.dart';
import 'package:Pedalcapp/widgets/Header.dart';
import 'package:Pedalcapp/widgets/InfoRow.dart';
import 'package:Pedalcapp/widgets/MapGoogle.dart';
import 'package:Pedalcapp/widgets/PassengerDetailForm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:Pedalcapp/classes/FareCalculatorHourly.dart';
import 'package:intl/intl.dart';

class PassengerDetailHourly extends StatefulWidget {
  const PassengerDetailHourly({super.key});

  @override
  State<PassengerDetailHourly> createState() => _PassengerDetailState();
}

class _PassengerDetailState extends State<PassengerDetailHourly> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  PhoneNumber number = PhoneNumber(isoCode: 'US');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final booking = Provider.of<BookingHourly>(context);

    final String dateOfService = booking.date;

// Convert string to DateTime
    final DateTime parsedDate = DateTime.parse(dateOfService);

//formatted date
    final String formattedDate = DateFormat('MM/dd/yyyy').format(parsedDate);

// Get the name of the day
    final String dayName = DateFormat('EEEE').format(parsedDate);

// Combine date, day name, and (Today) with spaces
    final String dateWithDayName = '$formattedDate $dayName (Today)';

    double convertToMinutes(String timeString) {
      // Split the string by space to separate the number and the unit.
      List<String> parts = timeString.split(' ');

      // Get the numeric value as an integer.
      double value = double.parse(parts[0]);

      // Determine the unit and convert accordingly.
      String unit =
          parts[1].toLowerCase(); // Convert to lowercase for case insensitivity

      if (unit == 'minute' || unit == 'minutes') {
        // If the unit is minutes, return the value directly.
        return value;
      } else if (unit == 'hour' || unit == 'hours') {
        // If the unit is hours, multiply by 60 to convert to minutes.
        return value * 60;
      } else {
        // Handle unexpected cases
        throw ArgumentError('Unexpected time unit: $unit');
      }
    }

    double serviceDurationInMinutes = convertToMinutes(booking.serviceDuration);
    // This function updates the fare calculation based on user input
    Future<void> _updateFareCalculation() async {
      final fareCalculator = FareCalculatorHourly(
          origin: booking.startAddressLatLng.toString(),
          destination: booking.destinationAddressLatLng.toString(),
          paymentMethod: booking.paymentMethod,
          serviceDuration: serviceDurationInMinutes);

      final fareDetails = await fareCalculator.calculateFare();

      setState(() {
        booking.bookingFee = double.parse(fareDetails['bookingFee']);
        booking.driverFee = double.parse(fareDetails['driverFare']);
        booking.totalFare = double.parse(fareDetails['totalFare']);
        booking.pickupDuration = double.parse(fareDetails['pickupsuresi']);
        booking.returnDuration = double.parse(fareDetails['returnsuresi']);
      });
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Header(
                  subtitle: "Hourly Pedicab Service",
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  height: 400,
                  child: MapGoogle(
                    pickupLatLng: booking.startAddressLatLng,
                    destinationLatLng: booking.destinationAddressLatLng,
                  ),
                ),
                const SizedBox(height: 20),
                InfoRow(
                    label: "Number of Passengers",
                    value: booking.numberOfPassengers.toString()),
                InfoRow(label: "Date of Service", value: dateWithDayName),
                const InfoRow(
                    label: "Time of Service", value: 'As Soon As Possible'),
                InfoRow(
                    label: "Duration of Service",
                    value: booking.serviceDuration),
                InfoRow(label: "Start Address", value: booking.startAddress),
                InfoRow(
                    label: "Finish Address", value: booking.destinationAddress),
                InfoRow(
                    label: "Service Details", value: booking.serviceDetails),
                FeeDetail(
                  booking: booking,
                ),
                const SizedBox(height: 20),
                PassengerDetailForm(
                  booking: booking,
                ),
                const SizedBox(height: 15),
                CustomButton(
                    buttonText: 'Review',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        //  await _updateFareCalculation();
                        Navigator.pushNamed(context, "/reviewDetailsHourly");
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
