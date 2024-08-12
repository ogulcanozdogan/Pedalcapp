import 'package:Pedalcapp/models/BookingCentral.dart';
import 'package:Pedalcapp/widgets/CustomButton.dart';
import 'package:Pedalcapp/widgets/FeeDetail.dart';
import 'package:Pedalcapp/widgets/Header.dart';
import 'package:Pedalcapp/widgets/InfoRow.dart';
import 'package:Pedalcapp/widgets/MapGoogle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ReviewDetailsCentral extends StatefulWidget {
  const ReviewDetailsCentral({super.key});

  @override
  State<ReviewDetailsCentral> createState() => _ReviewDetailsState();
}

class _ReviewDetailsState extends State<ReviewDetailsCentral> {
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
                const InfoRow(
                  label: "Type",
                  value: "On Demand Central Pedicab Tour",
                ),
                InfoRow(label: "First Name", value: booking.firstName),
                InfoRow(label: "Last Name", value: booking.lastName),
                InfoRow(label: "Email Address", value: booking.emailAddress),
                InfoRow(label: "Phone Number", value: booking.phoneNumber),
                InfoRow(
                  label: "Number of passengers",
                  value: booking.numberOfPassengers.toString(),
                ),
                InfoRow(label: "Date of Pick Up", value: dateWithDayName),
                const InfoRow(
                  label: "Time of Pick Up",
                  value: 'As Soon As Possible',
                ),
                InfoRow(
                  label: "Duration of Service",
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
                const SizedBox(height: 15),
                CustomButton(
                  buttonText: 'Book Now',
                  onPressed: () {
                    Navigator.pushNamed(context, "/paymentScreenCentral");
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
