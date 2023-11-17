import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mhike/widgets/position.dart';


class MySelectLocation extends StatefulWidget {
  const MySelectLocation({super.key});
  @override
  State<MySelectLocation> createState() => _MySelectLocationState();
}
class _MySelectLocationState extends State<MySelectLocation> {
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();
  Set<Marker> _manyMarker = {};
  TextEditingController _originController = TextEditingController();
  Placemark _address = Placemark();

  void _addMarker(LatLng markerPoints) async {
    final List<Placemark> placemarks = await placemarkFromCoordinates(
      markerPoints.latitude,
      markerPoints.longitude,
    );
    if (placemarks.isNotEmpty) {
      _address = placemarks[0];
    }
    setState(() {
      _manyMarker.clear();
      _manyMarker.add(Marker(
          markerId: MarkerId(
              'Marker ${_manyMarker.length+1}'
          ),
          position: LatLng(markerPoints.latitude, markerPoints.longitude),
          infoWindow: InfoWindow(
              title: _address == null
                  ? 'Position ${_manyMarker.length+1}'
                  : '${_address.street}',
              snippet: _address == null ?
              'latitude: ${markerPoints.latitude}, longtitude: ${markerPoints.longitude}.'
                  : '${_address.street}, ${_address.postalCode}, ${_address.administrativeArea},'
                  '${_address.country}'
          )
      ));
    });
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 15,
  );




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: Column(
        children: [
          Container(
              child: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        controller: _originController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: 'Search Place',
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    ElevatedButton(
                        onPressed: () async {
                          final place = await PositionServices()
                              .getPlaceDetails(_originController.text);
                          _gotoPlace(place['geometry']['location']['lat'],
                              place['geometry']['location']['lng']);
                        },
                        child: Text('Search Place'))
                  ],
                ),
              )
          ),
          Expanded(
            child: GoogleMap(
              markers: Set<Marker>.from(_manyMarker),
              onTap: (position) async {
                List<Placemark> placemarks = await placemarkFromCoordinates(
                    position.latitude,position.longitude);
                _address = placemarks[0];
                _addMarker(position);
              },
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_originController.text.isNotEmpty) {
                final place = await PositionServices().getPlaceDetails(_originController.text);
                final selectedLocation = {
                  'lat': place['geometry']['location']['lat'],
                  'lng': place['geometry']['location']['lng'],
                };
                Navigator.pop(context, selectedLocation);
              } else {
                if (_manyMarker.isNotEmpty) {
                  final markerPoints = _manyMarker.first.position;
                  final selectedLocation = {
                    'lat': markerPoints.latitude,
                    'lng': markerPoints.longitude,
                  };
                  Navigator.pop(context, selectedLocation);
                } else {
                  // Xử lý khi cả _originController và _manyMarker đều trống
                  // ở đây bạn có thể hiển thị thông báo hoặc thực hiện hành động khác.
                  // Ví dụ:
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Please enter a location or select a marker."),
                  ));
                }
              }
            },
            child: const Text('Pick'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed:() async {
            Position currentPosition = await PositionServices().getCurrentPosition();
            _goCurrentPosition(currentPosition.latitude, currentPosition.longitude);
          },
          child: const Icon(Icons.pin_drop_outlined)
      ),
    );
  }

  Future<void> _gotoPlace(double lat, double lng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 15)
    ));
    _addMarker(LatLng(lat, lng));
  }
  Future<void> _goCurrentPosition(double lat, double lng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 15)
    ));
    _addMarker(LatLng(lat, lng));
  }

}

