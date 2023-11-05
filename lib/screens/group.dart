import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mhike/screens/createhike.dart';
import 'package:mhike/screens/join.dart';

class Group extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const Group({Key? key});

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
        children: [
          Row(
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
                child: const Text('Create Hike'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Join()),
                  );
                },
                child: const Text('Join Hike'),
              ),
            ],
          ),
         SizedBox(
           height: 5,
         ),
          Container(
            width: 300,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(width: 1))
            ),
          ),
          SizedBox(height: 5,),
          Container(
            height: 600,
            child:_buildHikeList(),
          )
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
                            'The hike starts at ${timings?.toDate().toString()}'),
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
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      'Start Location: $startLocation',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        const SizedBox(height: 8),
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
