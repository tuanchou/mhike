import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mhike/screens/observation.dart';

import '../screens/description.dart';
import '../screens/detail_observation.dart';

class ObservationItem extends StatelessWidget {
  final String imageUrl;
  final Timestamp date;
  final String description;

  ObservationItem({required this.imageUrl, required this.date, required this.description});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the detail page when the item is clicked
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailObservation(
              imageUrl: imageUrl,
              date: date,
              description: description,
            ),
          ),
        );
      },
      child: ListTile(
        leading: Container(
          width: 80, // Set the desired width
          height: 80, // Set the desired height
          child: Image.network(imageUrl),
        ),
        title: Text(description),
        subtitle: Text("Date: ${date.toDate()}"),
      ),
    );
  }
}
