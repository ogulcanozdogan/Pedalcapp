import 'package:Pedalcapp/widgets/InfoRow.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeeDetail extends StatelessWidget {
  final dynamic booking;
  const FeeDetail({Key? key, this.booking}) : super(key: key);

  getDateWithDayName() {
    final String dateOfService = booking.date;

    // Convert string to DateTime
    final DateTime parsedDate = DateTime.parse(dateOfService);

    //formatted date
    final String formattedDate = DateFormat('MM/dd/yyyy').format(parsedDate);

    // Get the name of the day
    final String dayName = DateFormat('EEEE').format(parsedDate);

    // Combine date, day name, and (Today) with spaces
    final String dateWithDayName = '$formattedDate $dayName';

    return dateWithDayName;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InfoRow(
          label: "Booking Fee",
          value:
              "\$${booking.bookingFee.toStringAsFixed(2)} paid on ${getDateWithDayName()}",
        ),
        InfoRow(
          label: "Driver Fare",
          value:
              "\$${booking.driverFee.toStringAsFixed(2)} with ${booking.paymentMethod == 'CASH' ? 'CASH' : 'debit/credit card'} due on ${getDateWithDayName()}",
        ),
        InfoRow(
          label: "Total Fare",
          value: "\$${booking.totalFare.toStringAsFixed(2)}",
          backgroundColor: const Color.fromARGB(255, 40, 167, 69),
          foregroundColor: Colors.white,
          fontSize: 18,
        ),
      ],
    );
  }
}
