import 'package:Pedalcapp/models/BookingCentral.dart';
import 'package:Pedalcapp/widgets/CustomButton.dart';
import 'package:Pedalcapp/widgets/FeeDetail.dart';
import 'package:Pedalcapp/widgets/Header.dart';
import 'package:Pedalcapp/widgets/InfoRow.dart';
import 'package:Pedalcapp/widgets/MapGoogle.dart';
import 'package:Pedalcapp/widgets/PassengerDetailForm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Pedalcapp/classes/FareCalculatorCentral.dart';
import 'package:intl/intl.dart';

class PassengerDetailCentral extends StatefulWidget {
  const PassengerDetailCentral({super.key});

  @override
  State<PassengerDetailCentral> createState() => _PassengerDetailState();
}

class _PassengerDetailState extends State<PassengerDetailCentral> {
  @override
  void initState() {
    super.initState();
    _calculateFareAndSetDuration();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _calculateFareAndSetDuration() async {
    final booking = Provider.of<BookingCentral>(context, listen: false);

    final fareCalculator = FareCalculatorCentral(
      origin: booking.startAddress,
      destination: booking.destinationAddress,
      paymentMethod: booking.paymentMethod,
      serviceDuration: double.parse(booking.serviceDuration),
    );

    await fareCalculator.calculateFare();
    booking.combinedDuration = fareCalculator.combinedDuration;
  }

  @override
  Widget build(BuildContext context) {
    final booking = Provider.of<BookingCentral>(context);

    final String dateOfService = booking.date;

    // Convert string to DateTime
    final DateTime parsedDate = DateTime.parse(dateOfService);

    //formatted date
    final String formattedDate = DateFormat('MM/dd/yyyy').format(parsedDate);

    // Get the name of the day
    final String dayName = DateFormat('EEEE').format(parsedDate);

    // Combine date, day name, and (Today) with spaces
    final String dateWithDayName = '$formattedDate $dayName (Today)';

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
                  subtitle: "Central Park Tour",
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
                  value: booking.numberOfPassengers.toString(),
                ),
                InfoRow(label: "Date of Tour", value: dateWithDayName),
                const InfoRow(
                  label: "Time of Tour",
                  value: 'As Soon As Possible',
                ),
                InfoRow(
                  label: "Duration of Tour",
                  value: "${booking.serviceDuration} Minutes",
                ),
                InfoRow(
                  label: "Duration of Ride",
                  value:
                      "${booking.combinedDuration.toStringAsFixed(2)} Minutes",
                ),
                InfoRow(label: "Start Address", value: booking.startAddress),
                InfoRow(
                  label: "Finish Address",
                  value: booking.destinationAddress,
                ),
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
                      Navigator.pushNamed(context, "/reviewDetailsCentral");
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
