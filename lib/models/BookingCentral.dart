import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingCentral with ChangeNotifier {
  String _bookingNumber = "";
  int _numberOfPassengers = 1;
  String _date = "";
  String _startAddress = "";
  LatLng _startAddressLatLng = const LatLng(0, 0);
  String _destinationAddress = "";
  LatLng _destinationAddressLatLng = const LatLng(0, 0);
  String _paymentMethod = "";
  String _firstName = "";
  String _lastName = "";
  String _emailAddress = "";
  String _phoneNumber = "";
  num _bookingFee = 0.0;
  num _driverFee = 0.0;
  num _totalFare = 0.0;
  DateTime _createdAt = DateTime.now();
  DateTime _updatedAt = DateTime.now();
  String _status = "";
  num _pickupDuration = 0.0;
  num _rideDuration = 0.0;
  num _returnDuration = 0.0;
  num _tourDuration = 0.0;
  String _serviceDetails = "";
  String _serviceDuration = ""; // Yeni eklendi
  num _combinedDuration = 0.0; // Yeni eklendi

  // Getter ve Setter metodları
  String get bookingNumber => _bookingNumber;
  int get numberOfPassengers => _numberOfPassengers;
  String get date => _date;
  String get startAddress => _startAddress;
  LatLng get startAddressLatLng => _startAddressLatLng;
  String get destinationAddress => _destinationAddress;
  LatLng get destinationAddressLatLng => _destinationAddressLatLng;
  String get paymentMethod => _paymentMethod;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get emailAddress => _emailAddress;
  String get phoneNumber => _phoneNumber;
  num get bookingFee => _bookingFee;
  num get driverFee => _driverFee;
  num get totalFare => _totalFare;
  DateTime get createdAt => _createdAt;
  DateTime get updatedAt => _updatedAt;
  String get status => _status;
  num get pickupDuration => _pickupDuration;
  num get rideDuration => _rideDuration;
  num get returnDuration => _returnDuration;
  num get tourDuration => _tourDuration;
  String get serviceDetails => _serviceDetails;
  String get serviceDuration => _serviceDuration; // Yeni eklendi
  num get combinedDuration => _combinedDuration; // Yeni eklendi

  set bookingNumber(String value) {
    _bookingNumber = value;
    notifyListeners();
  }

  set numberOfPassengers(int value) {
    _numberOfPassengers = value;
    notifyListeners();
  }

  set date(String value) {
    _date = value;
    notifyListeners();
  }

  set startAddress(String value) {
    _startAddress = value;
    notifyListeners();
  }

  set startAddressLatLng(LatLng value) {
    _startAddressLatLng = value;
    notifyListeners();
  }

  set destinationAddress(String value) {
    _destinationAddress = value;
    notifyListeners();
  }

  set destinationAddressLatLng(LatLng value) {
    _destinationAddressLatLng = value;
    notifyListeners();
  }

  set paymentMethod(String value) {
    _paymentMethod = value;
    notifyListeners();
  }

  set firstName(String value) {
    _firstName = value;
    notifyListeners();
  }

  set lastName(String value) {
    _lastName = value;
    notifyListeners();
  }

  set emailAddress(String value) {
    _emailAddress = value;
    notifyListeners();
  }

  set phoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  set bookingFee(num value) {
    _bookingFee = value;
    notifyListeners();
  }

  set driverFee(num value) {
    _driverFee = value;
    notifyListeners();
  }

  set totalFare(num value) {
    _totalFare = value;
    notifyListeners();
  }

  set createdAt(DateTime value) {
    _createdAt = value;
    notifyListeners();
  }

  set updatedAt(DateTime value) {
    _updatedAt = value;
    notifyListeners();
  }

  set status(String value) {
    _status = value;
    notifyListeners();
  }

  set pickupDuration(num value) {
    _pickupDuration = value;
    notifyListeners();
  }

  set rideDuration(num value) {
    _rideDuration = value;
    notifyListeners();
  }

  set returnDuration(num value) {
    _returnDuration = value;
    notifyListeners();
  }

  set tourDuration(num value) {
    _tourDuration = value;
    notifyListeners();
  }

  set serviceDetails(String value) {
    _serviceDetails = value;
    notifyListeners();
  }

  set serviceDuration(String value) {
    _serviceDuration = value;
    notifyListeners();
  }

  set combinedDuration(num value) {
    _combinedDuration = value;
    notifyListeners();
  }

  void updateFareDetails(num bookingFee, num driverFee, num totalFare) {
    _bookingFee = bookingFee;
    _driverFee = driverFee;
    _totalFare = totalFare;
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingNumber': _bookingNumber,
      'numberOfPassengers': _numberOfPassengers,
      'startAddress': _startAddress,
      'startAddressLatLng': {
        'latitude': _startAddressLatLng.latitude,
        'longitude': _startAddressLatLng.longitude,
      },
      'destinationAddress': _destinationAddress,
      'destinationAddressLatLng': {
        'latitude': _destinationAddressLatLng.latitude,
        'longitude': _destinationAddressLatLng.longitude,
      },
      'paymentMethod': _paymentMethod,
      'firstName': _firstName,
      'lastName': _lastName,
      'emailAddress': _emailAddress,
      'phoneNumber': _phoneNumber,
      'bookingFee': _bookingFee,
      'driverFee': _driverFee,
      'totalFare': _totalFare,
      'createdAt': _createdAt,
      'updatedAt': _updatedAt,
      'status': _status,
      'pickupDuration': _pickupDuration,
      'rideDuration': _rideDuration,
      'returnDuration': _returnDuration,
      'tourDuration': _tourDuration,
      'serviceDetails': _serviceDetails,
      'serviceDuration': _serviceDuration,
      'combinedDuration': _combinedDuration, // Yeni eklendi
    };
  }
}
