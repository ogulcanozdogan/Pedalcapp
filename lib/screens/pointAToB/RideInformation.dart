import 'package:Pedalcapp/classes/FareCalculator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as webservice_places;
import 'package:provider/provider.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:Pedalcapp/models/Booking.dart';
import 'package:Pedalcapp/widgets/CustomButton.dart';
import 'package:Pedalcapp/widgets/Header.dart';
import 'ReviewDetails.dart';

class RideInformation extends StatefulWidget {
  const RideInformation({super.key});
  @override
  State<RideInformation> createState() => _RideInformationState();
}

class _RideInformationState extends State<RideInformation> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _numberOfPassengers = 1;
  String? _paymentOption = 'CASH'; // default payment option
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  LatLng pickupLatLng = const LatLng(0, 0);
  LatLng destinationLatLng = const LatLng(0, 0);
  String pickupPlaceId = "";
  String destinationPlaceId = "";
  bool isKeyboardVisible = false;
  bool _isPickupFieldActive = true;
  DateTime? _selectedDate;

  List<String> hours = List<String>.generate(
      12, (index) => (index + 1).toString().padLeft(2, '0'));
  List<String> minutes = ['00', '15', '30', '45'];
  List<String> periods = ['AM', 'PM'];

  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  final LatLng _manhattanSouthWest =
      LatLng(40.70172445894308, -74.02835332961955);
  final LatLng _manhattanNorthEast =
      LatLng(40.81370673870937, -73.91583560578955);

  final List<String> _allowedPostalCodes = [
    '10000',
    '10001',
    '10002',
    '10003',
    '10004',
    '10005',
    '10006',
    '10007',
    '10008',
    '10009',
    '10010',
    '10011',
    '10012',
    '10013',
    '10014',
    '10015',
    '10016',
    '10017',
    '10018',
    '10019',
    '10020',
    '10021',
    '10022',
    '10023',
    '10024',
    '10025',
    '10026',
    '10028',
    '10029',
    '10036',
    '10038',
    '10041',
    '10043',
    '10045',
    '10055',
    '10060',
    '10065',
    '10069',
    '10075',
    '10080',
    '10081',
    '10087',
    '10090',
    '10101',
    '10102',
    '10103',
    '10104',
    '10105',
    '10106',
    '10107',
    '10108',
    '10109',
    '10110',
    '10111',
    '10112',
    '10113',
    '10114',
    '10116',
    '10117',
    '10118',
    '10119',
    '10120',
    '10121',
    '10122',
    '10123',
    '10124',
    '10126',
    '10128',
    '10129',
    '10130',
    '10131',
    '10132',
    '10133',
    '10138',
    '10151',
    '10152',
    '10153',
    '10154',
    '10155',
    '10156',
    '10157',
    '10158',
    '10159',
    '10160',
    '10162',
    '10163',
    '10164',
    '10165',
    '10166',
    '10167',
    '10168',
    '10169',
    '10170',
    '10171',
    '10172',
    '10173',
    '10174',
    '10175',
    '10176',
    '10177',
    '10178',
    '10179',
    '10185',
    '10199',
    '10203',
    '10211',
    '10212',
    '10242',
    '10249',
    '10256',
    '10258',
    '10259',
    '10260',
    '10261',
    '10265',
    '10268',
    '10269',
    '10270',
    '10271',
    '10272',
    '10273',
    '10274',
    '10275',
    '10276',
    '10277',
    '10278',
    '10279',
    '10280',
    '10281',
    '10282',
    '10285',
    '10286'
  ];

  List<webservice_places.Prediction> _predictions = [];

  @override
  void initState() {
    super.initState();
    _pickupFocusNode.addListener(() {
      setState(() {
        isKeyboardVisible = _pickupFocusNode.hasFocus;
      });
    });

    _destinationFocusNode.addListener(() {
      setState(() {
        isKeyboardVisible = _destinationFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _pickupFocusNode.dispose();
    _destinationFocusNode.dispose();
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Klavyeyi kapat
      FocusScope.of(context).unfocus();
      setState(() {
        isKeyboardVisible = false;
      });

      final fareCalculator = FareCalculator(
        origin: _pickupController.text,
        destination: _destinationController.text,
        paymentMethod: _paymentOption.toString(),
      );

      final result = await fareCalculator.calculateFare();

      // Update the Booking model with fare details
      var booking = Provider.of<Booking>(context, listen: false);
      booking.updateFareDetails(
        double.parse(result['bookingFee']),
        double.parse(result['driverFare']),
        double.parse(result['totalFare']),
      );
      booking.startAddress = _pickupController.text;
      booking.destinationAddress = _destinationController.text;
      booking.date =
          DateFormat('yyyy-MM-dd').format(_selectedDate ?? DateTime.now());
      booking.startAddressLatLng = pickupLatLng;
      booking.destinationAddressLatLng = destinationLatLng;
      booking.pickupDuration = double.parse(result['pickupsuresi']);
      booking.rideDuration = double.parse(result['ridesuresi']);
      booking.returnDuration = double.parse(result['returnsuresi']);
      booking.paymentMethod = _paymentOption.toString();
      booking.numberOfPassengers = _numberOfPassengers;

      // Navigate to PassengerDetail page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReviewDetails()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: Stack(
              children: [
                ListView(
                  children: [
                    const Header(
                      subtitle: "Point A to B Pedicab Ride",
                    ),
                    const SizedBox(height: 25),
                    const Text("Number of passengers"),
                    const SizedBox(height: 5),
                    DropdownButtonFormField(
                      items: <String>['1', '2', '3']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _numberOfPassengers = int.parse(value.toString());
                        });
                      },
                      value: _numberOfPassengers.toString(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        hintText: "Number of passengers",
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Number of passengers is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    const Text("Pick up address"),
                    const SizedBox(height: 5),
                    _buildPlaceAutoCompleteTextField(
                        _pickupController, _pickupFocusNode, "Pick up address"),
                    _isPickupFieldActive ? _buildPredictionList() : Container(),
                    const SizedBox(height: 15),
                    const Text("Destination address"),
                    const SizedBox(height: 5),
                    _buildPlaceAutoCompleteTextField(_destinationController,
                        _destinationFocusNode, "Destination address"),
                    !_isPickupFieldActive
                        ? _buildPredictionList()
                        : Container(),
                    const SizedBox(height: 15),
                    const Text("Driver Payment"),
                    const SizedBox(height: 5),
                    ListTile(
                      dense: true,
                      title: const Text('I will pay the driver cash',
                          style: TextStyle(fontSize: 14)),
                      contentPadding: const EdgeInsets.all(0),
                      leading: Radio(
                        value: 'CASH',
                        groupValue: _paymentOption,
                        onChanged: (String? value) {
                          setState(() {
                            _paymentOption = value!;
                          });
                        },
                        activeColor: Colors.black,
                      ),
                    ),
                    ListTile(
                      dense: true,
                      title: const Text(
                        'I will pay the driver with debit/credit card (10% fee applies)',
                        style: TextStyle(fontSize: 14),
                      ),
                      contentPadding: const EdgeInsets.all(0),
                      leading: Radio(
                        value: 'CARD',
                        groupValue: _paymentOption,
                        onChanged: (String? value) {
                          setState(() {
                            _paymentOption = value!;
                          });
                        },
                        activeColor: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 15),
                    CustomButton(
                        buttonText: 'Continue',
                        onPressed: () {
                          _submitForm();
                        })
                  ],
                ),
                if (isKeyboardVisible)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: FloatingActionButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          isKeyboardVisible = false;
                        });
                      },
                      child: const Icon(Icons.keyboard_hide),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceAutoCompleteTextField(
      TextEditingController controller, FocusNode focusNode, String hintText) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field cannot be empty';
        }
        return null;
      },
      onChanged: (value) {
        _onPlaceSearchChanged(value, hintText);
      },
      onTap: () {
        setState(() {
          _isPickupFieldActive = (hintText == "Pick up address");
        });
      },
    );
  }

  Future<void> _onPlaceSearchChanged(String value, String hintText) async {
    if (value.isEmpty) {
      setState(() {
        _predictions.clear();
      });
      return;
    }

    final headers = await GoogleApiHeaders().getHeaders();
    final places = webservice_places.GoogleMapsPlaces(
        apiKey: "AIzaSyBg9HV0g-8ddiAHH6n2s_0nXOwHIk2f1DY", apiHeaders: headers);

    final response = await places.autocomplete(
      value,
      location: webservice_places.Location(
          lat:
              (_manhattanSouthWest.latitude + _manhattanNorthEast.latitude) / 2,
          lng: (_manhattanSouthWest.longitude + _manhattanNorthEast.longitude) /
              2),
      radius: _calculateDistance(
              _manhattanSouthWest.latitude,
              _manhattanSouthWest.longitude,
              _manhattanNorthEast.latitude,
              _manhattanNorthEast.longitude) /
          2 *
          1000,
      strictbounds: false,
      types: ['geocode', 'establishment'],
    );

    if (response.isOkay) {
      setState(() {
        _predictions = response.predictions;
      });
    } else {
      setState(() {
        _predictions.clear();
      });
    }
  }

  Widget _buildPredictionList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _predictions.length,
      itemBuilder: (context, index) {
        final prediction = _predictions[index];
        return ListTile(
          title: Text(prediction.description ?? ""),
          onTap: () async {
            final placeDetails = await _getPlaceDetails(prediction.placeId!);
            if (placeDetails != null &&
                _isValidPostalCode(placeDetails.result.addressComponents) &&
                _isWithinBounds(placeDetails.result.geometry?.location)) {
              final formattedAddress = _formatAddress(
                placeDetails.result.addressComponents,
                placeDetails.result.formattedAddress ?? '',
                placeDetails.result.name,
              );
              setState(() {
                if (_isPickupFieldActive) {
                  _pickupController.text = formattedAddress;
                  pickupLatLng = LatLng(
                      placeDetails.result.geometry?.location.lat ?? 0.0,
                      placeDetails.result.geometry?.location.lng ?? 0.0);
                  pickupPlaceId = prediction.placeId ?? "";
                } else {
                  _destinationController.text = formattedAddress;
                  destinationLatLng = LatLng(
                      placeDetails.result.geometry?.location.lat ?? 0.0,
                      placeDetails.result.geometry?.location.lng ?? 0.0);
                  destinationPlaceId = prediction.placeId ?? "";
                }
                _predictions.clear();
              });
            } else {
              _showInvalidLocationAlert();
            }
          },
        );
      },
    );
  }

  Future<webservice_places.PlacesDetailsResponse?> _getPlaceDetails(
      String placeId) async {
    try {
      final headers = await GoogleApiHeaders().getHeaders();
      final places = webservice_places.GoogleMapsPlaces(
          apiKey: "AIzaSyBg9HV0g-8ddiAHH6n2s_0nXOwHIk2f1DY",
          apiHeaders: headers);
      final response = await places.getDetailsByPlaceId(placeId);

      if (response.status == 'OK') {
        return response;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  String _formatAddress(
      List<webservice_places.AddressComponent> addressComponents,
      String formattedAddress,
      String customPlaceName) {
    for (var component in addressComponents) {
      if (component.types.contains('street_number')) {}
      if (component.types.contains('route')) {}
      if (component.types.contains('locality')) {}
      if (component.types.contains('postal_code')) {}
    }

    String addressWithoutCountry = formattedAddress.replaceAll(', USA', '');
    if (customPlaceName.isNotEmpty &&
        !addressWithoutCountry.contains(customPlaceName)) {
      return '$addressWithoutCountry ($customPlaceName)';
    }
    return addressWithoutCountry;
  }

  bool _isValidPostalCode(
      List<webservice_places.AddressComponent> addressComponents) {
    for (var component in addressComponents) {
      if (component.types.contains('postal_code') &&
          _allowedPostalCodes.contains(component.longName)) {
        return true;
      }
    }
    return false;
  }

  bool _isWithinBounds(webservice_places.Location? location) {
    if (location == null) return false;
    return location.lat >= _manhattanSouthWest.latitude &&
        location.lat <= _manhattanNorthEast.latitude &&
        location.lng >= _manhattanSouthWest.longitude &&
        location.lng <= _manhattanNorthEast.longitude;
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Pi / 180
    final a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
  }

  void _showInvalidLocationAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Invalid Location'),
          content: const Text(
              'Please select a location within Manhattan and the allowed postal codes.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
