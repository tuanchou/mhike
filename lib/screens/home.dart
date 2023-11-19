import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mhike/screens/createhike.dart';
import 'package:mhike/screens/description.dart';
import 'package:mhike/screens/group.dart';
import 'package:mhike/screens/profile.dart';
import 'capture.dart';

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _placesReference =
  FirebaseFirestore.instance.collection('hike');
  final CollectionReference _cultural =
  FirebaseFirestore.instance.collection('hike');
  late double latitude;
  late double longitude;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    String userId = user?.uid ?? "";

    return Scaffold(
      drawer: const Drawer(
        child: Text(""), // Menu content
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('./assets/images/bg.png'), // Replace with the actual path to your image
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              _buildDiscoverText(),
              _buildSearchBar(),
              _buildPlacesAndDescriptions(),
              _buildMyHikes(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 20,
          ),
          CircleAvatar(
            backgroundImage: AssetImage('assets/images/register.png'),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Discover the world!',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
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
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 11, 0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                suffixIcon: const Icon(
                  Icons.search,
                  color: Colors.black12,
                ),
                hintText: 'Search',
                hintStyle: const TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.7),
                  borderSide: BorderSide(width: 20.0, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPlacesAndDescriptions() {
    return _buildSection(
      'Places and Descriptions',
      _placesReference,
          (hikeId) => DetailPage(hikeId: hikeId),
    );
  }

  Widget _buildMyHikes() {
    return _buildSection(
      'My Hikes',
      _cultural,
            (hikeId) => DetailPage(hikeId: hikeId),
    );
  }

  Widget _buildSection(
      String sectionTitle,
      CollectionReference collectionReference,
      Widget Function(String) navigateTo,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            sectionTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 210,
          child: FutureBuilder<QuerySnapshot>(
            future: collectionReference.get(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  String hikeId = documents[index].id; // Replace with the actual field name
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => navigateTo(hikeId), // Pass the hikeId
                        ),
                      );
                    },
                    child: Container(
                      width: 150,
                      height: 200,
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Image.network(
                              documents[index]['imageUrl'],
                              height: 180,
                              width: 150,
                              fit: BoxFit.cover,
                            ),
                            Text(
                              documents[index]['title'],
                              style: const TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyHome()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.navigation),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Group()),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.camera_alt,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Capture()),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.account_circle_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Profile()),
              );
            },
          ),
        ],
      ),
    );
  }
}
