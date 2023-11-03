import 'package:flutter/material.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 100,
              child: Center(
                child: Text('Address'),
              ),
            ),
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
              height: 500,
              child: Center(
                child: OpenStreetMapSearchAndPick(
                  center: LatLong(23, 89),
                  buttonColor: Colors.yellow,
                  buttonText: 'Set Current Location',
                  onPicked: (pickedData) {
                    // print(pickedData.latLong.latitude);
                    // print(pickedData.latLong.longitude);
                    // print(pickedData.address);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
