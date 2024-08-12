import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class FareCalculator {
  final String origin;
  final String destination;
  final String paymentMethod;
  static const String _apiKey = 'AIzaSyBg9HV0g-8ddiAHH6n2s_0nXOwHIk2f1DY';
  static const String _hubLocation = '40.766941088678855, -73.97899952992152';

  FareCalculator({
    required this.origin,
    required this.destination,
    required this.paymentMethod,
  });

  /// Method to calculate fare details.
  Future<Map<String, dynamic>> calculateFare() async {
    final _currentDate = DateTime.now();
    final _dayOfWeek = DateFormat('EEEE').format(_currentDate);
    final _month = DateFormat('MMMM').format(_currentDate);

    double pickupDuration =
        await _getShortestBicycleRouteDuration(_hubLocation, origin);
    double rideDuration =
        await _getShortestBicycleRouteDuration(origin, destination);
    double returnDuration =
        await _getShortestBicycleRouteDuration(destination, _hubLocation);

    
    
    
    

    // Calculate operation fare
    double pickupTime = pickupDuration * 2.5;
    double returnTime = returnDuration * 2.5;
    double rideTime = rideDuration * 2.5;

    
    
    
    

    double totalDurationMinutes = pickupTime + rideTime + returnTime;
    
    
    double operationFarePerHour =
        _calculateOperationFarePerHour(_dayOfWeek, _month);
    double operationFare = (totalDurationMinutes / 60) * operationFarePerHour;
    
    

    // Calculate booking fee and driver fare
    double bookingFee;
    double driverFare;
    if (paymentMethod == "CARD" || paymentMethod == "CASH") {
      bookingFee = 0.2 * operationFare;
      driverFare = 0.8 * operationFare;
      if (paymentMethod == "CARD") {
        driverFare *= 1.1;
      }
    } else {
      bookingFee = 0.3 * operationFare;
      driverFare = 0.7 * operationFare;
    }

    final Map<String, Map<String, Map<String, num>>> minFares = {
      "CASH": {
        "week": {"Booking Fee": 3.75, "Driver Fare": 15, "Total Fare": 18.75},
        "weekend": {"Booking Fee": 4.5, "Driver Fare": 18, "Total Fare": 22.5},
        "weekDecember": {"Booking Fee": 5, "Driver Fare": 20, "Total Fare": 25},
        "weekendDecember": {
          "Booking Fee": 6,
          "Driver Fare": 24,
          "Total Fare": 30
        },
      },
      "CARD": {
        "week": {"Booking Fee": 3.75, "Driver Fare": 16.5, "Total Fare": 20.25},
        "weekend": {
          "Booking Fee": 4.5,
          "Driver Fare": 19.8,
          "Total Fare": 24.3
        },
        "weekDecember": {"Booking Fee": 5, "Driver Fare": 22, "Total Fare": 27},
        "weekendDecember": {
          "Booking Fee": 6,
          "Driver Fare": 26.4,
          "Total Fare": 32.4
        },
      },
      "fullcard": {
        "week": {"Booking Fee": 3.75, "Driver Fare": 16.5, "Total Fare": 20.25},
        "weekend": {
          "Booking Fee": 4.5,
          "Driver Fare": 19.8,
          "Total Fare": 24.3
        },
        "weekDecember": {"Booking Fee": 5, "Driver Fare": 22, "Total Fare": 27},
        "weekendDecember": {
          "Booking Fee": 6,
          "Driver Fare": 26.4,
          "Total Fare": 32.4
        },
      },
    };

    final isWeekend = _dayOfWeek == "Friday" ||
        _dayOfWeek == "Saturday" ||
        _dayOfWeek == "Sunday";
    final key = (isWeekend ? "weekend" : "week") +
        (_month == "December" ? "December" : "");

    final double minBookingFee =
        (minFares[paymentMethod]![key]!["Booking Fee"] as num).toDouble();
    final double minDriverFare =
        (minFares[paymentMethod]![key]!["Driver Fare"] as num).toDouble();
    final double minTotalFare =
        (minFares[paymentMethod]![key]!["Total Fare"] as num).toDouble();

    bookingFee = bookingFee < minBookingFee ? minBookingFee : bookingFee;
    driverFare = driverFare < minDriverFare ? minDriverFare : driverFare;

    double totalFare;
    if (paymentMethod == "CARD" || paymentMethod == "CASH") {
      totalFare = (bookingFee + driverFare) < minTotalFare
          ? minTotalFare
          : (bookingFee + driverFare);
    } else {
      totalFare = (operationFare) * 1.2;
      totalFare = totalFare < minTotalFare ? minTotalFare : totalFare;
    }

    return {
      'bookingFee': bookingFee.toStringAsFixed(2),
      'driverFare': driverFare.toStringAsFixed(2),
      'totalFare': totalFare.toStringAsFixed(2),
      'pickupsuresi': pickupTime.toStringAsFixed(2),
      'ridesuresi': rideTime.toStringAsFixed(2),
      'returnsuresi': returnTime.toStringAsFixed(2),
      'dayOfWeek': _dayOfWeek,
      'month': _month,
    };
  }

Future<double> _getShortestBicycleRouteDuration(String start, String end) async {
    final Uri url = Uri.parse(
      "https://maps.googleapis.com/maps/api/directions/json?origin=${Uri.encodeComponent(start)}&destination=${Uri.encodeComponent(end)}&mode=bicycling&key=$_apiKey",
    );
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        int shortestDuration = 999999999;
        for (var route in data['routes']) {
          int routeDuration = 0;
          for (var leg in route['legs']) {
            routeDuration += leg['duration']['value'] as int;
          }
          if (routeDuration < shortestDuration) {
            shortestDuration = routeDuration;
          }
        }
        // Calculate the shortest duration in minutes with precise floating point calculations
        if (shortestDuration != 999999999) {
          final minutes = (shortestDuration / 60).floor();
          final seconds = shortestDuration % 60;
          return double.parse((minutes + seconds / 60).toStringAsFixed(2));
        }
      }
    }
    return 0.0;
}


  /// Helper method to calculate operation fare per hour
  double _calculateOperationFarePerHour(String dayOfWeek, String month) {
    final bool isWeekend = dayOfWeek == "Friday" ||
        dayOfWeek == "Saturday" ||
        dayOfWeek == "Sunday";

    if (month == "December") {
      return isWeekend ? 60.0 : 52.5;
    } else {
      return isWeekend ? 45.0 : 37.5;
    }
  }
}
