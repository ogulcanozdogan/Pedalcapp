import 'package:Pedalcapp/models/Booking.dart';
import 'package:Pedalcapp/widgets/CustomButton.dart';
import 'package:Pedalcapp/widgets/FeeDetail.dart';
import 'package:Pedalcapp/widgets/Header.dart';
import 'package:Pedalcapp/widgets/InfoRow.dart';
import 'package:Pedalcapp/widgets/MapGoogle.dart';
import 'package:Pedalcapp/widgets/PassengerDetailForm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:intl/intl.dart';

class PassengerDetail extends StatefulWidget {
  const PassengerDetail({super.key});

  @override
  State<PassengerDetail> createState() => _PassengerDetailState();
}

class _PassengerDetailState extends State<PassengerDetail> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  PhoneNumber number = PhoneNumber(isoCode: 'US');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final booking = Provider.of<Booking>(context);

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
                InfoRow(
                    label: "Number of Passengers",
                    value: booking.numberOfPassengers.toString()),
                InfoRow(label: "Date of Pick Up", value: dateWithDayName),
                const InfoRow(
                    label: "Time of Pick Up", value: 'As Soon As Possible'),
                InfoRow(
                    label: "Duration of Ride",
                    value:
                        "${booking.rideDuration.toStringAsFixed(2)} Minutes"),
                InfoRow(label: "Pick up address", value: booking.startAddress),
                InfoRow(
                    label: "Destination Address",
                    value: booking.destinationAddress),
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pushNamed(context, "/reviewDetails");
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
