
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


import 'createhike.dart';


class DetailPage extends StatefulWidget {
  final String? hikeId;

  const DetailPage({this.hikeId});

  @override
  State<DetailPage> createState() => _CreateDetailPage();
}

class _CreateDetailPage extends State<DetailPage> {
  double _starRating = 0;
  bool _parking = false;
  int _hikeLength = 0;
  String _imageUrl = 'null';
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();



  final CollectionReference _reference =
  FirebaseFirestore.instance.collection('hike');
  final CollectionReference _relations =
  FirebaseFirestore.instance.collection('hikes');
  String? startLocation;
  DateTime? date;
  final _auth = FirebaseAuth.instance;



  @override
  void initState() {
    super.initState();
    // Load existing data when the hikeId is provided
    if (widget.hikeId != null) {
      loadHikeData(widget.hikeId);
    }
  }

  Future<void> loadHikeData(String? hikeId) async {
    try {
      final DocumentSnapshot hikeSnapshot = await _reference.doc(hikeId).get();
      final QuerySnapshot observationQuery = await _relations
          .where('hike_id', isEqualTo: hikeId)
          .get();
      observationQuery.docs.forEach((QueryDocumentSnapshot document) {
        // Access data from the document
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        // Print the data
        print("Document ID: ${document.id}, Data: $data");
      });
      final hikeData = hikeSnapshot.data() as Map<String, dynamic>;

      if (hikeData != null) {
        setState(() {
          _titleController.text = hikeData['title'];
          _descriptionController.text = hikeData['description'];
          startLocation = hikeData['start'];
          date = hikeData['timings'].toDate(); // Assuming it's a DateTime
          _imageUrl = hikeData['imageUrl'];
          _parking = hikeData['parking'] ?? false;
          _hikeLength = hikeData['length'] ?? 0;
          _starRating = hikeData['level'] ?? 0.0;
        });
      }
    } catch (error) {
      print('Error loading hike data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hike Details'),
      ),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _titleController.text,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      letterSpacing: 1.2,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _descriptionController.text,
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Parking: ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _parking ? 'Available' : 'Not Available',
                        style: TextStyle(
                          fontSize: 20,
                          color: _parking ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Hike Length: $_hikeLength km',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Difficulty level:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  StarRatingWidget(
                    onRatingChanged: (rating) {},
                    initialRating: _starRating,
                  ),
                  SizedBox(height: 20),
                  FutureBuilder<QuerySnapshot>(
                    future: _relations
                        .where('hike_id', isEqualTo: widget.hikeId)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final observationQuery = snapshot.data!;
                        return CarouselSlider(
                          options: CarouselOptions(
                            height: 350,
                            enlargeCenterPage: true,
                          ),
                          items: observationQuery.docs.map((document) {
                            Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                            String imageUrl = data['image_url'];
                            String description = data['description'];

                            return Builder(
                              builder: (BuildContext context) {
                                return ListView(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                                      child: Column(
                                        children: [
                                          Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            height: 300,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            description,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );

                              },
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),

              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
