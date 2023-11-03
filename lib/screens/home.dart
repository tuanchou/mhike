import 'package:flutter/material.dart';
import 'package:mhike/screens/description.dart';
import 'package:mhike/screens/group.dart';
import 'package:mhike/screens/profile.dart';
import 'capture.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  String imageUrl = '';
  // final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference _placesReference =
  FirebaseFirestore.instance.collection('places');
  final CollectionReference _cultural =
  FirebaseFirestore.instance.collection('cultural');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(232, 244, 243, 0.765),
      drawer: const Drawer(
        // Small menu button
        child: Text(""), // Menu content,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 40, 16, 8), // Adjust padding as needed
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 30,
                  ),
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/register.png'),
                  ),
                ],
              ),
            ),
            // Discover text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Discover',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // "Explore the places of the world" text
            const Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 8, 16, 24), // Adjust padding as needed
              child: Text(
                'Explore the places of the world',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 11, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      autofocus: true,
                      decoration: InputDecoration(
                        suffixIcon: const Icon(
                          Icons.search,
                          color: Colors.black12,
                        ),
                        hintText: 'Search',
                        hintStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.7),
                            borderSide:
                                BorderSide(width: 20.0, color: Colors.black)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Places and Descriptions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 200,
              child: FutureBuilder<QuerySnapshot>(
                future: _placesReference.get(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                      String imageUrl = documents[index]['image'];
                      String description = documents[index]['description'];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Description(
                                imageUrl: imageUrl,
                                placeName: 'Place $index',
                                description: description,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 150,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Image.network(imageUrl),
                                Text(
                                  'Place $index',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Cultural Diversity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: FutureBuilder<QuerySnapshot>(
                future: _cultural.get(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                      String imageUrl = documents[index]['Imageurl'];
                      String description = documents[index]['Description'];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Description(
                                imageUrl: imageUrl,
                                placeName: 'Place $index',
                                description: description,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 150,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Image.network(imageUrl),
                                Text(
                                  'Place $index',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white),
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
            // Groups section
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
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
      ),
    );
  }
}

