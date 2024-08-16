import 'package:Pedalcapp/models/Booking.dart';
import 'package:Pedalcapp/widgets/CustomButton.dart';
import 'package:Pedalcapp/widgets/FeeDetail.dart';
import 'package:Pedalcapp/widgets/Header.dart';
import 'package:Pedalcapp/widgets/InfoRow.dart';
import 'package:Pedalcapp/widgets/MapGoogle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReviewDetails extends StatefulWidget {
  const ReviewDetails({super.key});

  @override
  State<ReviewDetails> createState() => _ReviewDetailsState();
}

class _ReviewDetailsState extends State<ReviewDetails> {
  String firstName = '';
  String lastName = '';
  String emailAddress = '';
  String phoneNumber = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        firstName = userDoc['firstName'] ?? '';
        lastName = userDoc['lastName'] ?? '';
        emailAddress = userDoc['email'] ?? '';
        phoneNumber = userDoc['phone'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = Provider.of<Booking>(context);

    final String dateOfService = booking.date;
    final DateTime parsedDate = DateTime.parse(dateOfService);
    final String formattedDate = DateFormat('MM/dd/yyyy').format(parsedDate);
    final String dayName = DateFormat('EEEE').format(parsedDate);
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
          child: ListView(
            children: [
              const Header(
                subtitle: "Point A to B Pedicab Ride",
              ),
              Container(
                margin: const EdgeInsets.only(top: 16),
                height: 400,
                child: MapGoogle(
                  pickupLatLng: booking.startAddressLatLng,
                  destinationLatLng: booking.destinationAddressLatLng,
                  showPolylines: true,
                ),
              ),
              const SizedBox(height: 20),
              const InfoRow(
                label: "Type",
                value: "On Demand Point A to B Pedicab Ride",
              ),
              InfoRow(label: "First Name", value: firstName),
              InfoRow(label: "Last Name", value: lastName),
              InfoRow(label: "Email Address", value: emailAddress),
              InfoRow(label: "Phone Number", value: phoneNumber),
              InfoRow(
                label: "Number of Passengers",
                value: booking.numberOfPassengers.toString(),
              ),
              InfoRow(label: "Date of Pick Up", value: dateWithDayName),
              const InfoRow(
                label: "Time of Pick Up",
                value: 'As Soon As Possible',
              ),
              InfoRow(
                label: "Duration of Ride",
                value: "${booking.rideDuration.toStringAsFixed(2)} Minutes",
              ),
              InfoRow(label: "Pick up address", value: booking.startAddress),
              InfoRow(
                label: "Destination Address",
                value: booking.destinationAddress,
              ),
              FeeDetail(
                booking: booking,
              ),
              const SizedBox(height: 15),
              CustomButton(
                buttonText: 'Book Now',
                onPressed: () {
                  Navigator.pushNamed(context, "/paymentScreen");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
