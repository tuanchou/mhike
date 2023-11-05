import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/observation_item.dart';

class ObservationScreen extends StatefulWidget {
  @override
  _ObservationScreenState createState() => _ObservationScreenState();
}

class _ObservationScreenState extends State<ObservationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Observations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("hike")
            .doc("THsBmqY9CZxmTsrJWukp")
            .collection("observations")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var observations = snapshot.data!.docs;

          if (observations.isEmpty) {
            return Center(child: Text('No observations found.'));
          }

          return ListView.builder(
            itemCount: observations.length,
            itemBuilder: (context, index) {
              var observation = observations[index];
              var imageUrl = observation['imageUrl'];
              var date = observation['date'];
              var description = observation['description'];

              return ObservationItem(
                imageUrl: imageUrl,
                date: date,
                description: description,
              );
            },
          );
        },
      ),
    );
  }
}
