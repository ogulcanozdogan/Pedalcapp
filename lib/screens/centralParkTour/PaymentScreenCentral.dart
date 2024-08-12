import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:Pedalcapp/models/BookingCentral.dart';
import 'package:Pedalcapp/widgets/CustomButton.dart';
import 'package:Pedalcapp/widgets/FeeDetail.dart';
import 'package:Pedalcapp/widgets/Header.dart';
import 'package:Pedalcapp/widgets/InfoRow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class PaymentScreenCentral extends StatefulWidget {
  const PaymentScreenCentral({super.key});

  @override
  State<PaymentScreenCentral> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreenCentral> {
  bool _isChecked = false;
  dynamic paymentIntent;

  void _toggleCheckbox(bool? value) {
    setState(() {
      _isChecked = value ?? false;
    });
  }

  getBookingNumber(final booking) {
    String day = DateFormat('dd').format(booking.createdAt);
    String month = DateFormat('MM').format(booking.createdAt);
    String year = DateFormat('yyyy').format(booking.createdAt);
    String hour = DateFormat('H').format(booking.createdAt);
    String minute = DateFormat('mm').format(booking.createdAt);

    String orderDate = "$year-$month-$day";
    String tourDate = "$year-$month-$day";
    String orderTime = "$hour-$minute";
    String tourTime = "$hour-$minute";

    var uuid = Uuid();
    String generatedUuid = uuid.v4();

    String finalUuid = generatedUuid.replaceAll('-', '');
    finalUuid = finalUuid.substring(0, 16);

    return "$tourDate-$tourTime-$orderDate-$orderTime-$finalUuid";
  }

  // Function to generate a UUID-like string
  String generateUUID() {
    final randomBytes = _generateRandomBytes(16);
    return _bytesToHex(randomBytes);
  }

// Helper function to generate random bytes
  Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
        List.generate(length, (_) => random.nextInt(256)));
  }

// Helper function to convert bytes to a hexadecimal string
  String _bytesToHex(Uint8List bytes) {
    final buffer = StringBuffer();
    for (var byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  displayPaymentSheet(final booking) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        //Clear paymentIntent variable after successful payment
        paymentIntent = null;
        final db = FirebaseFirestore.instance;
        DateTime now = DateTime.now();
        booking.createdAt = now;
        booking.updatedAt = now;

        final bookingNumber = getBookingNumber(booking);
        booking.bookingNumber = bookingNumber;

        db.collection("bookings").doc(bookingNumber).set(booking.toMap());
        Navigator.pushNamed(context, "/BookingConfirmationScreenCentral");
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
    } catch (e) {
      print('$e');
    }
  }

  calculateAmount(String amount) {
    int calculatedAmount = (double.parse(amount) * 100).toInt();
    return calculatedAmount.toString();
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  Future<void> makePayment(final booking, final bookingFee) async {
    try {
      //STEP 1: Create Payment Intent
      paymentIntent = await createPaymentIntent('$bookingFee', 'USD');

      //STEP 2: Initialize Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              customFlow: false,

              paymentIntentClientSecret:
                  paymentIntent!['client_secret'], //Gotten from payment intent
              style: ThemeMode.light,
              merchantDisplayName: 'Pedalcapp',
              applePay: const PaymentSheetApplePay(
                merchantCountryCode: 'US',
              ),
              googlePay: const PaymentSheetGooglePay(
                merchantCountryCode: 'US',
                testEnv: true,
              ),
            ),
          )
          .then((value) {});

      //STEP 3: Display Payment sheet
      displayPaymentSheet(booking);
    } catch (err) {
      throw Exception(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = Provider.of<BookingCentral>(context);
    final bookingFee = booking.bookingFee.toString();

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
                const InfoRow(
                    label: "Type", value: "On Demand Central Pedicab Tour"),
                InfoRow(label: "First Name", value: booking.firstName),
                InfoRow(label: "Last Name", value: booking.lastName),
                InfoRow(label: "Email Address", value: booking.emailAddress),
                InfoRow(label: "Phone Number", value: booking.phoneNumber),
                InfoRow(
                    label: "Number of Passengers",
                    value: booking.numberOfPassengers.toString()),
                InfoRow(label: "Date of Pick Up", value: dateWithDayName),
                const InfoRow(
                    label: "Time of Pick Up", value: 'As Soon As Possible'),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: _toggleCheckbox,
                      activeColor: Colors.black,
                    ),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Optionally, toggle the checkbox when the label is tapped
                          _toggleCheckbox(!_isChecked);
                        },
                        child: const Text(
                          'I confirm that I am ready to get picked up now.',
                          style: TextStyle(fontSize: 15.0),
                          softWrap: true,
                        ),
                      ),
                    ),
                    // Add some space between the checkbox and the label
                  ],
                ),
                const SizedBox(height: 15),
                CustomButton(
                    buttonText: 'Pay \$$bookingFee',
                    onPressed: !_isChecked
                        ? null
                        : () {
                            makePayment(booking, bookingFee);
                          })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
