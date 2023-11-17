import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
                          builder: (context) => const CreateHike()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue, // Set the desired color
                  ),
                  child: const Text('Create Hike'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Join()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green, // Set the desired color
                  ),
                  child: const Text('Join Hike'),
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('hike').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Error retrieving data',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final hikes = snapshot.data?.docs;

        if (hikes == null || hikes.isEmpty) {
          return const Center(
            child: Text(
              'No hikes available',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: hikes.length,
          itemBuilder: (BuildContext context, int index) {
            final hikeData = hikes[index].data() as Map<String, dynamic>;

            final startLocation = hikeData['start'] as String?;
            final endLocation = hikeData['end'] as String?;
            final timings = hikeData['timings'] as Timestamp?;

            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Hike Information'),
                      content: Text(
                        'The hike starts at ${timings?.toDate().toString()}',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Card(
                margin: const EdgeInsets.all(8),
                elevation: 2, // Add elevation for a subtle shadow
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Location: $startLocation',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'End Location: $endLocation',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors
                              .blue, // Set the desired color for end location
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Timings: ${timings?.toDate().toString()}',
                        style: const TextStyle(
                          fontSize: 14,
                          color:
                              Colors.green, // Set the desired color for timings
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
