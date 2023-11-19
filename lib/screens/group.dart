import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mhike/screens/createhike.dart';
import 'package:mhike/screens/join.dart';

class Group extends StatefulWidget {
  const Group({Key? key}) : super(key: key);

  @override
  State<Group> createState() => _GroupState();
}

class _GroupState extends State<Group> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateHike(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                  ),
                  child: const Text(
                    'Create Hike',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Join(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                  ),
                  child: const Text(
                    'Join Hike',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _buildHikeList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHikeList() {
    final user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? "";

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('hike').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error retrieving data',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final hikes = snapshot.data?.docs;

        if (hikes == null || hikes.isEmpty) {
          return Center(
            child: Text(
              'No hikes available',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        final userHikes = hikes.where((hike) => hike['userId'] == userId).toList();

        if (userHikes.isEmpty) {
          return Center(
            child: Text(
              'No hikes available for the current user',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: userHikes.length,
          itemBuilder: (BuildContext context, int index) {
            final hikeData = userHikes[index].data() as Map<String, dynamic>;

            final title = hikeData['title'] as String?;
            final description = (hikeData['description'] as String?)?.trim();
            final startTime = hikeData['timings'] as Timestamp?;
            final formattedDate =
            startTime != null ? DateFormat('yyyy-MM-dd').format(startTime.toDate()) : 'Not available';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateHike(hikeId: userHikes[index].id),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.all(8),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Title: $title',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Description: $description',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Start Date: $formattedDate',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

}
