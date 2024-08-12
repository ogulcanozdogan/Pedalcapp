import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class FareCalculatorCentral {
  final String origin;
  final String destination;
  final String paymentMethod;
  final double serviceDuration;
  static const String _apiKey = 'AIzaSyBg9HV0g-8ddiAHH6n2s_0nXOwHIk2f1DY';
  static const String _hub1Location = '40.766941088678855, -73.97899952992152';
  static const String _hub2Location =
      '6th Avenue and Central Park South New York, NY 10019';
  double? _combinedDuration;

  FareCalculatorCentral({
    required this.origin,
    required this.destination,
    required this.paymentMethod,
    required this.serviceDuration,
  });

  Future<Map<String, dynamic>> calculateFare() async {
    final _currentDate = DateTime.now();
    final _dayOfWeek = DateFormat('EEEE').format(_currentDate);
    final _month = DateFormat('MMMM').format(_currentDate);

    double pickup1Duration =
        await _getShortestBicycleRouteDuration(_hub1Location, origin);
    double pickup2Duration =
        await _getShortestBicycleRouteDuration(origin, _hub2Location);
    double tourDuration =
        await _getShortestBicycleRouteDuration(origin, destination);
    double return1Duration =
        await _getShortestBicycleRouteDuration(_hub1Location, destination);
    double return2Duration =
        await _getShortestBicycleRouteDuration(destination, _hub2Location);

    pickup1Duration *= 2.5;
    pickup2Duration *= 2.5;
    return1Duration *= 2.5;
    return2Duration *= 2.5;

    double totalMinutes = pickup1Duration +
        pickup2Duration +
        return1Duration +
        return2Duration +
        serviceDuration;
    double combinedDuration =
        pickup2Duration + serviceDuration + return1Duration;

    _combinedDuration = combinedDuration;

    double totalHours = totalMinutes / 60;
    double hourlyOperationFare =
        _calculateOperationFarePerHour(_dayOfWeek, _month);
    double operationFare = totalHours * hourlyOperationFare;

    double bookingFee = 0.2 * operationFare;
    double driverFare = 0.8 * operationFare;

    if (paymentMethod.toUpperCase() == "CARD") {
      driverFare *= 1.1;
    }

    double totalFare = bookingFee + driverFare;

    return {
      'bookingFee': bookingFee.toStringAsFixed(2),
      'driverFare': driverFare.toStringAsFixed(2),
      'totalFare': totalFare.toStringAsFixed(2),
      'pickup1Duration': pickup1Duration.toString(),
      'pickup2Duration': pickup2Duration.toString(),
      'tourDuration': tourDuration.toStringAsFixed(2),
      'return1Duration': return1Duration.toString(),
      'return2Duration': return2Duration.toString(),
      'combinedDuration': combinedDuration.toStringAsFixed(2),
      'dayOfWeek': _dayOfWeek,
      'month': _month,
    };
  }

  double get combinedDuration => _combinedDuration ?? 0.0;

  Future<double> _getShortestBicycleRouteDuration(
      String start, String end) async {
    final Uri url = Uri.parse(
      "https://maps.googleapis.com/maps/api/directions/json?origin=${Uri.encodeComponent(start)}&destination=${Uri.encodeComponent(end)}&mode=bicycling&alternatives=true&key=$_apiKey",
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
        if (shortestDuration != 999999999) {
          final minutes = (shortestDuration / 60).floor();
          final seconds = shortestDuration % 60;
          return double.parse((minutes + seconds / 60).toStringAsFixed(2));
        }
      }
    }
    return 0.0;
  }

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
