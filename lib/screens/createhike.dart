import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mhike/screens/selectlocation.dart';


class CreateHike extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const CreateHike({Key? key});

  @override
  State<CreateHike> createState() => _CreateHikeState();
}

class _CreateHikeState extends State<CreateHike> {
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('hike');
  String? startLocation;
  String? endLocation;
  DateTime? date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Hike'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MySelectLocation(),
                  ),
                ).then((value)  {
                  if (value != null) {
                    setState(() async {
                      startLocation = "Latitude: ${value['lat']}, Longitude: ${value['lng']}";
                    });
                  }
                });
              },
              child: const Text('Select Start Location'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MySelectLocation(),
                  ),
                ).then((value) {
                  if (value != null) {
                    setState(() {
                      endLocation =  "Latitude: ${value['lat']}, Longitude: ${value['lng']}";
                    });
                  }
                });
              },
              child: const Text('Select End Location'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                ).then((value) {
                  if (value != null) {
                    setState(() {
                      date = value;
                    });
                  }
                });
              },
              child: const Text('Select Date'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Start Location:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              startLocation ?? 'Not selected',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blue, // Set start location text color
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'End Location:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              endLocation ?? 'Not selected',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.green, // Set end location text color
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Date:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              date?.toString() ?? 'Not selected',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red, // Set date text color
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitData,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }



  Future<void> _submitData() async {
    if (startLocation == null || endLocation == null || date == null) {
      print('Please fill all the fields');
      return;
    }

    try {
      await _reference.add({
        'start': startLocation,
        'end': endLocation,
        'timings': date,
      });
      // Data saved successfully, show success message or navigate to the next screen
    } catch (error) {
      // Handle error, show error message or retry logic
      print('Error saving data: $error');
    }
  }
}
