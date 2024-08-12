import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class FareCalculatorHourly {
  final String origin;
  final String destination;
  final String paymentMethod;
  final double serviceDuration;  // Changed rideDuration to serviceDuration
  static const String _apiKey = 'AIzaSyBg9HV0g-8ddiAHH6n2s_0nXOwHIk2f1DY';
  static const String _hubLocation = '40.766941088678855, -73.97899952992152';

  FareCalculatorHourly({
    required this.origin,
    required this.destination,
    required this.paymentMethod,
    required this.serviceDuration,  // Changed rideDuration to serviceDuration
  });

  /// Method to calculate fare details.
  Future<Map<String, dynamic>> calculateFare() async {
    final _currentDate = DateTime.now();
    final _dayOfWeek = DateFormat('EEEE').format(_currentDate);
    final _month = DateFormat('MMMM').format(_currentDate);

    double pickupDuration =
        await _getShortestBicycleRouteDuration(_hubLocation, origin);
    double returnDuration =
        await _getShortestBicycleRouteDuration(destination, _hubLocation);

    // Adjusting durations based on the logic from PHP code
    pickupDuration *= 2.5;
    returnDuration *= 2.5;

    // Calculate total operation duration
    double totalMinutes = pickupDuration + serviceDuration + returnDuration;

    
    // Convert total duration to hours
    double totalHours = totalMinutes / 60;

    // Determine the hourly operation fare based on the day of the week and month
    double hourlyOperationFare = _calculateOperationFarePerHour(_dayOfWeek, _month);
    double operationFare = totalHours * hourlyOperationFare;

    // Calculate booking fee and driver fare
    double bookingFee = 0.2 * operationFare;
    double driverFare = 0.8 * operationFare;

    if (paymentMethod.toUpperCase() == "CARD") {
      driverFare *= 1.1;
    }

    // Calculate total fare
    double totalFare = bookingFee + driverFare;

    return {
      'bookingFee': bookingFee.toStringAsFixed(2),
      'driverFare': driverFare.toStringAsFixed(2),
      'totalFare': totalFare.toStringAsFixed(2),
      'pickupsuresi': pickupDuration.toString(),// Changed rideDuration to serviceDuration
      'returnsuresi': returnDuration.toString(),
      'dayOfWeek': _dayOfWeek,
      'month': _month,
    };
  }

  /// Helper method to get the shortest bicycle route duration
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
        // Calculate the shortest duration in minutes
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
