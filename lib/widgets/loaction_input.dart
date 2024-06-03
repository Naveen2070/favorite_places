import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LoactionInput extends StatefulWidget {
  const LoactionInput({super.key});

  @override
  State<LoactionInput> createState() => _LoactionInputState();
}

class _LoactionInputState extends State<LoactionInput> {
  Location? _pickedLoaction;
  var _isFetching = false;

  void _getCurrentLoctaion() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isFetching = true;
    });

    locationData = await location.getLocation();

    setState(() {
      _isFetching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text("No loacation added",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ));

    if (_isFetching) {
      previewContent = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              border: Border.all(
                  width: 1,
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.2))),
          height: 200,
          width: double.infinity,
          alignment: Alignment.center,
          child: previewContent,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          TextButton.icon(
            onPressed: _getCurrentLoctaion,
            label: const Text("Get Current Location"),
            icon: const Icon(
              Icons.location_on,
            ),
          ),
          TextButton.icon(
              onPressed: () {},
              label: const Text("Select on Map"),
              icon: const Icon(
                Icons.map,
              ))
        ])
      ],
    );
  }
}
