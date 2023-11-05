import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class PositionServices {
  final String API_KEY = 'AIzaSyD2i_ssamvfXexYZobe9u0QKgZRXomJhx4';
  final String baseUrl = 'https://maps.googleapis.com/maps/api/place';

  Future<String> getPlaceId(String searchInput) async {
    final String url = 
        '$baseUrl/findplacefromtext/json?input=$searchInput&inputtype=textquery&key=$API_KEY';

    var response = await http.get(Uri.parse(url));
    var jsonResponse = convert.jsonDecode(response.body);
    var placeId = jsonResponse['candidates'][0]['place_id'] as String;
    return(placeId);
  }

  Future<Map<String, dynamic>> getPlaceDetails(String place) async {
    final placeId = await getPlaceId(place);
    final String url = '$baseUrl/details/json?place_id=$placeId&key=$API_KEY';
    var response = await http.get(Uri.parse(url));
    var jsonResponse = convert.jsonDecode(response.body);
    var placeDetails = jsonResponse['result'] as Map<String, dynamic>;

    return placeDetails;
  }
  Future<Position> getCurrentPosition() async {
    bool servicesEnabled;
    LocationPermission permission;
    servicesEnabled = await Geolocator.isLocationServiceEnabled();
    if(!servicesEnabled){
      return Future.error('Location services permissions are disabled');
    }
    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if(permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.'
      );
    }
    return await Geolocator.getCurrentPosition();
  }
}