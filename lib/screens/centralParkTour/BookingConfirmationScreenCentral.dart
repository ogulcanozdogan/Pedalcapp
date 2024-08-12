import 'package:Pedalcapp/models/BookingCentral.dart';
import 'package:Pedalcapp/widgets/FeeDetail.dart';
import 'package:Pedalcapp/widgets/InfoRow.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class BookingConfirmationScreenCentral extends StatefulWidget {
  const BookingConfirmationScreenCentral({super.key});

  @override
  State<BookingConfirmationScreenCentral> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends State<BookingConfirmationScreenCentral> {
  late String tourTimeFormatted;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
  }

  @override
  Widget build(BuildContext context) {
    final booking = Provider.of<BookingCentral>(context);

    // Initialize time zones
    final nyTimeZone = tz.getLocation('America/New_York');

    // current time
    final now = tz.TZDateTime.now(nyTimeZone);

    // Tour Time
    final pickupDuration = booking.pickupDuration;

    // Tour Time
    final pickup1Minutes = pickupDuration.floor();
    final pickup1Seconds = ((pickupDuration - pickup1Minutes) * 60).floor();

    // Tour Time
    var tourTime = now.add(Duration(minutes: 5)); // + 5 dakika
    tourTime = tourTime.add(Duration(
        minutes: pickup1Minutes, seconds: pickup1Seconds)); // + Pick Up 1

    // Tour Time
    tourTimeFormatted = DateFormat('hh:mm a').format(tourTime);

    final String dateOfService = booking.date;

    // Convert string to DateTime
    final DateTime parsedDate = DateTime.parse(dateOfService);

    //formatted date
    final String formattedDate = DateFormat('MM/dd/yyyy').format(parsedDate);

    // Get the name of the day
    final String dayName = DateFormat('EEEE').format(parsedDate);

    // Combine date, day name, and (Today) with spaces
    final String dateWithDayName = '$formattedDate $dayName';

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
            child: ListView(
              children: [
                const Text("Booking Confirmation",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        height: 0,
                        fontSize: 30,
                        fontWeight: FontWeight.bold)),
                const Expanded(
                    child: Text("Thank you for choosing Pedalcapp",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 1),
                            fontSize: 14,
                            fontWeight: FontWeight.bold))),
                const Expanded(
                    child: Text(
                        "Below are the confirmed details of your booking:",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 1),
                            fontSize: 14,
                            fontWeight: FontWeight.bold))),
                const SizedBox(height: 15),
                InfoRow(label: "Booking Number", value: booking.bookingNumber),
                const InfoRow(
                    label: "Type", value: "On Demand Central Pedicab Tour"),
                InfoRow(label: "First Name", value: booking.firstName),
                InfoRow(label: "Last Name", value: booking.lastName),
                InfoRow(label: "Email Address", value: booking.emailAddress),
                InfoRow(label: "Phone Number", value: booking.phoneNumber),
                InfoRow(
                    label: "Number of Passengers",
                    value: booking.numberOfPassengers.toString()),
                InfoRow(
                  label: "Date of Service",
                  value: "${dateWithDayName} (Today)",
                ),
                InfoRow(label: "Time of Service", value: tourTimeFormatted),
                InfoRow(
                    label: "Duration of Service",
                    value: "${booking.serviceDuration} Minutes"),
                InfoRow(
                  label: "Duration of Ride",
                  value:
                      "${booking.combinedDuration.toStringAsFixed(2)} Minutes",
                ),
                InfoRow(label: "Start Address", value: booking.startAddress),
                InfoRow(
                    label: "Finish Address", value: booking.destinationAddress),
                FeeDetail(
                  booking: booking,
                ),
                const SizedBox(height: 15),
                const Expanded(
                    child: Text("Thank you,",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.bold))),
                const Expanded(
                    child: Text("Pedalcapp",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.bold))),
                const Expanded(
                    child: Text("(212) 961-7435",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.bold))),
                const Expanded(
                    child: Text("info@newyorkpedicabservices.com",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.bold))),
                const Expanded(
                    child: Text("newyorkpedicabservices.com",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}