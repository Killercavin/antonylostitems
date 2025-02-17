import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lostitems/Constants.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({Key? key}) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  String address = "No address selected";
  String autocompletePlace = "No place selected";
  Prediction? selectedPrediction;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Picker'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Box for Places Autocomplete
              PlacesAutocomplete(
                searchController: _searchController,
                apiKey: GOOGLEMAPAPI_KEY,
                debounceDuration: const Duration(milliseconds: 500),
                searchHintText: "Search for a place",
                mounted: mounted, // Use the mounted property from State
                onGetDetailsByPlaceId: (PlacesDetailsResponse? result) {
                  if (result != null) {
                    setState(() {
                      autocompletePlace = result.result.formattedAddress ?? "Unknown address";
                    });
                    debugPrint("Place details fetched: ${result.result.formattedAddress}");
                  } else {
                    debugPrint("Failed to fetch place details.");
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Search for a Place'),
                      content: PlacesAutocomplete(
                        apiKey: GOOGLEMAPAPI_KEY,
                        searchHintText: "Type to search...",
                        debounceDuration: const Duration(milliseconds: 500),
                        mounted: mounted, // Use the mounted property from State
                        onSelected: (Prediction value) {
                          setState(() {
                            selectedPrediction = value;
                            autocompletePlace = value.structuredFormatting?.mainText ?? "Unknown place";
                          });
                          debugPrint("Place selected: $autocompletePlace");
                        },
                        onGetDetailsByPlaceId: (PlacesDetailsResponse? result) {
                          if (result != null) {
                            setState(() {
                              address = result.result.formattedAddress ?? "Unknown address";
                            });
                            debugPrint("Place details fetched: ${result.result.formattedAddress}");
                          }
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapLocationPicker(
                        apiKey: GOOGLEMAPAPI_KEY,
                        popOnNextButtonTaped: true,
                        currentLatLng: const LatLng(1.0388, 37.0834),
                        debounceDuration: const Duration(milliseconds: 500),
                        onNext: (GeocodingResult? result) {
                          if (result != null) {
                            setState(() {
                              address = result.formattedAddress ?? "Unknown address";
                            });
                            debugPrint("Location picked: ${result.formattedAddress}");
                          }
                        },
                        onSuggestionSelected: (PlacesDetailsResponse? result) {
                          if (result != null) {
                            setState(() {
                              autocompletePlace = result.result.formattedAddress ?? "Unknown place";
                            });
                            debugPrint("Suggestion selected: ${result.result.formattedAddress}");
                          }
                        },
                      ),
                    ),
                  );
                },
                child: const Text('Pick Location from Map'),
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text("Selected Address: $address"),
              ),
              ListTile(
                leading: const Icon(Icons.place),
                title: Text("Autocomplete Place: $autocompletePlace"),
              ),
              const Divider(height: 32),
              TextButton(
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: "https://www.mohesu.com")).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Link copied to clipboard")),
                    );
                  });
                },
                child: const Text("https://www.mohesu.com"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
