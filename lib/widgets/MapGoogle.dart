import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io' as io;
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapGoogle extends StatefulWidget {
  final LatLng pickupLatLng;
  final LatLng destinationLatLng;
  final bool showPolylines;

  const MapGoogle(
      {super.key,
      required this.pickupLatLng,
      required this.destinationLatLng,
      this.showPolylines = false});

  @override
  _MapGoogleState createState() => _MapGoogleState();
}

class _MapGoogleState extends State<MapGoogle> {
  Map<PolylineId, Polyline> polylines = {};
  String apiKey = io.Platform.isAndroid
      ? "AIzaSyCLLcqngf1PHHbvIuvJu9-qxh6aQwAtbCw"
      : "AIzaSyBg9HV0g-8ddiAHH6n2s_0nXOwHIk2f1DY";

  @override
  void initState() {
    super.initState();
    getShortestRouteAndPolyline(widget.pickupLatLng, widget.destinationLatLng)
        .then((coordinates) => {generatePolylineFromPoints(coordinates)});
  }

  @override
  Widget build(BuildContext context) {
    bool showPolylines = widget.showPolylines;
    return Scaffold(
        body: GoogleMap(
      initialCameraPosition: CameraPosition(
          target: LatLng(
              (widget.pickupLatLng.latitude +
                      widget.destinationLatLng.latitude) /
                  2,
              (widget.pickupLatLng.longitude +
                      widget.destinationLatLng.longitude) /
                  2),
          zoom: 12.0),
      markers: {
        Marker(
            markerId: const MarkerId("pickupLatLng"),
            icon: BitmapDescriptor.defaultMarker,
            position: widget.pickupLatLng),
        Marker(
            markerId: const MarkerId("destinationLatLng"),
            position: widget.destinationLatLng)
      },
      polylines: showPolylines ? Set<Polyline>.of(polylines.values) : {},
    ));
  }

  Future<List<LatLng>> getShortestRouteAndPolyline(
      LatLng pickupLatLng, LatLng destinationLatLng) async {
    List<LatLng> polylineCoordinates = [];

    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${pickupLatLng.latitude},${pickupLatLng.longitude}&destination=${destinationLatLng.latitude},${destinationLatLng.longitude}&mode=bicycling&alternatives=true&key=$apiKey');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var routes = data['routes'];
      var shortestRouteIndex = findShortestRouteIndex(routes);
      var overviewPolyline = routes[shortestRouteIndex]['overview_polyline']['points'];
      
      polylineCoordinates = decodePolyline(overviewPolyline);
    } else {
      print('Failed to load directions API');
    }

    return polylineCoordinates;
  }

  int findShortestRouteIndex(List<dynamic> routes) {
    var index = 0;
    var minDuration = double.infinity;

    for (var i = 0; i < routes.length; i++) {
      var route = routes[i];
      var legs = route['legs'];
      var totalDuration = legs.fold(0, (sum, leg) => sum + leg['duration']['value']);

      if (totalDuration < minDuration) {
        minDuration = totalDuration.toDouble();
        index = i;
      }
    }

    return index;
  }

  List<LatLng> decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0;
    int len = polyline.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
    }
    return points;
  }

  void generatePolylineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
        width: 8);
    setState(() {
      polylines[id] = polyline;
    });
  }
}
