import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Hike {
  final String title;
  final String description;
  final String startLocation;
  final DateTime startTime;
  final String imageUrl;

  Hike({
    required this.title,
    required this.description,
    required this.startLocation,
    required this.startTime,
    required this.imageUrl,
  });
}

class RelationsHike {
  final String description;
  final String imageUrl;

  RelationsHike({
    required this.description,
    required this.imageUrl,
  });
}

class DetailPage extends StatefulWidget {
  final String hikeId;

  DetailPage({required this.hikeId});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _hikeData;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _relationHikeData;
  late double latitude;
  late double longitude;

  @override
  void initState() {
    super.initState();
    _hikeData = _fetchHikeData(widget.hikeId);
    _relationHikeData = _fetchRelationHikeData(widget.hikeId);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchHikeData(String hikeId) async {
    return await FirebaseFirestore.instance.collection('hike').doc(hikeId).get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchRelationHikeData(String hikeId) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('hikes')
        .where('hike_id', isEqualTo: hikeId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    } else {
      // Handle the case when the document is not found
      throw Exception('Document not found for hikeId: $hikeId');
    }
  }

  void _extractLatLng(String startLocation) {
    List<String> coordinates = startLocation
        .replaceAll('Latitude: ', '')
        .replaceAll('Longitude: ', '')
        .split(', ');

    if (coordinates.length == 2) {
      latitude = double.parse(coordinates[0]);
      longitude = double.parse(coordinates[1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hike Detail'),
      ),
      body: FutureBuilder(
        future: Future.wait([_hikeData, _relationHikeData]),
        builder: (context, AsyncSnapshot<List<DocumentSnapshot<Map<String, dynamic>>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.any((doc) => !doc.exists)) {
            return Center(child: Text('Hike or related data not found'));
          }

          Map<String, dynamic> data = snapshot.data![0].data() as Map<String, dynamic>;
          Map<String, dynamic> relation = snapshot.data![1].data() as Map<String, dynamic>;
          RelationsHike relationsHike = RelationsHike(description: relation['description'], imageUrl: relation['image_url']);
          print(relationsHike);
          Hike hike = Hike(
            title: data['title'],
            description: data['description'],
            startLocation: data['start'],
            startTime: data['timings'].toDate(),
            imageUrl: data['imageUrl'],
          );

          _extractLatLng(hike.startLocation);

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              _buildDetailItem('Title', hike.title),
              _buildDetailItem('Description', hike.description),
              _buildDetailItem('Start Location', hike.startLocation),
              _buildDetailItem('Start Time', hike.startTime.toString()),
              Container(
                height: 140,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(latitude, longitude),
                    zoom: 15.0,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('hike_location'),
                      position: LatLng(latitude, longitude),
                      infoWindow: InfoWindow(title: hike.title),
                    ),
                  },
                ),
              ),
              SizedBox(height: 16.0),
              _buildImageSlider([relationsHike.imageUrl], [relationsHike.description]), // Pass a list of image URLs
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSlider(List<String> imageUrls, List<String> descriptions) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        enableInfiniteScroll: true,
        autoPlay: true,
      ),
      items: imageUrls.map((imageUrl) {
        return Builder(
          builder: (BuildContext context) {
            return Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 100.0, // Adjust the height as needed
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  descriptions[imageUrls.indexOf(imageUrl)],
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            );
          },
        );
      }).toList(),
    );
  }

}
