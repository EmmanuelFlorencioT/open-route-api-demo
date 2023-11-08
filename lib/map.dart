import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:open_route/utils/networking.dart';

class MyMap extends StatefulWidget {
  const MyMap({super.key});

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  late GoogleMapController mapController;

  late LatLng _center = const LatLng(45.521523, -122.677433);

  //Store the points with the coordinates (lat, lng)
  final List<LatLng> polyPoints = [];

  //Store the lines on the map
  final Set<Polyline> polyLines = {}; //Polyline comes from the GoogleMaps API

  @override
  void initState() {
    getJsonData();
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> getJsonData() async {
    NetworkHelper networkHelper = NetworkHelper(
      startLat: 22.144596,
      startLng: -101.009064,
      endLat: 22.149730,
      endLng: -100.992221,
    );

    try {
      var data;
      //Call to the openroute API that gets the coordinates
      data = await networkHelper.getData();
      print(data);
      print(data['features']);
      print(data['features'][0]);
      print(data['features'][0]['geometry']);
      print(data['features'][0]['geometry']['coordinates']);
      LineString ls =
          LineString(data['features'][0]['geometry']['coordinates']);

      for (int i = 0; i < ls.lineString.length; i++) {
        print('${ls.lineString[i][1]}, ${ls.lineString[i][0]}');
        polyPoints.add(LatLng(ls.lineString[i][1], ls.lineString[i][0]));
      }

      if (polyPoints.length == ls.lineString.length) {
        setPolyLines();
      }
    } catch (e) {
      print('There was an error fetching the data from the API');
    }
  }

  setPolyLines() {
    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId('polyline'),
        color: Colors.red,
        width: 5,
        points: polyPoints,
      );
      polyLines.add(polyline);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Map',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            polylines: polyLines,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11,
            ),
          ),
        ],
      ),
    );
  }
}

//Convert the String to an Array
class LineString {
  LineString(this.lineString);
  List<dynamic> lineString;
}
