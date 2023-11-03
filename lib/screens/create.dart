import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:get/get.dart';
import 'package:mhike/state/main_state.dart';

class MyCreateHike extends StatefulWidget {
  const MyCreateHike({super.key});
  @override
  State<MyCreateHike> createState() => _MyCreateHikeState();
}

class _MyCreateHikeState extends State<MyCreateHike> {
  var controller = Get.put(MainStateController());
  var textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Hike",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: textController,
                ),
              ),
              IconButton(
                  onPressed: () async {
                    controller.isLoading.value = true;
                    var data = await addressSuggestion(textController.text);
                    if (data.isNotEmpty) {
                      controller.listSource.value = data;
                    }
                    controller.isLoading.value = false;
                  },
                  icon: Icon(Icons.search_outlined))
            ],
          ),
          Obx(
            () => Expanded(
              child: controller.listSource.isEmpty
                  ? Container()
                  : ListView.builder(itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            controller.listSource[index].address.toString()),
                      );
                    }),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {}, child: const Icon(Icons.pin_drop_outlined)),
    );
  }
}
