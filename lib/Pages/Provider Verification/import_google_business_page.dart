// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/const.dart';

import '../../Controllers/user_controller.dart';
import '../setup_business_provider.dart';
// import 'package:google_maps_webservice/places.dart';

class ImportGoogleBusinessPage extends StatefulWidget {
  const ImportGoogleBusinessPage({super.key});

  @override
  _ImportGoogleBusinessPageState createState() =>
      _ImportGoogleBusinessPageState();
}

class _ImportGoogleBusinessPageState extends State<ImportGoogleBusinessPage> {
  final TextEditingController _controller = TextEditingController();
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: apiKey);
  List<Prediction> _results = [];
  bool isLoading = false;

  Future<void> _searchBusinesses() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    setState(() {
      isLoading = true;
    });
    final response = await _places.autocomplete(
      query,
      types: ['establishment'],
    );

    setState(() {
      _results = response.predictions;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: Text('Import My Business',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Enter your business name',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchBusinesses,
                ),
              ),
              onFieldSubmitted: (value) {
                _searchBusinesses();
              },
              onSaved: (value) {
                _searchBusinesses();
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : _results.isEmpty
                      ? Center(child: Text("No results yet."))
                      : ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final suggestion = _results[index];
                            return ListTile(
                              title: Text(suggestion.description ?? ''),
                              onTap: () async {
                                Get.dialog(LoadingDialog(), useSafeArea: false);
                                final detail = await _places
                                    .getDetailsByPlaceId(suggestion.placeId!);
                                final place = detail.result;
                                final isAutoRepair =
                                    place.types.contains('car_repair');
                                Get.close(1);
                                if (isAutoRepair) {
                                  Get.to(() => SetupBusinessProvider(
                                      placeDetails: place));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Selected business is not an auto repair shop.")),
                                  );
                                }
                              },
                              trailing: Icon(Icons.arrow_forward_ios_outlined),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class BusinessDetailPage extends StatelessWidget {
  final PlaceDetails place;

  const BusinessDetailPage({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
          ),
        ),
        title: Text(
          'Import My Business',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${place.name}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("Address: ${place.formattedAddress ?? ''}"),
            SizedBox(height: 8),
            Text("Phone: ${place.formattedPhoneNumber ?? 'N/A'}"),
            SizedBox(height: 8),
            Text("Website: ${place.website ?? 'N/A'}"),
            SizedBox(height: 8),
            Text(
                "Phone with Country: ${place.internationalPhoneNumber ?? 'N/A'}"),
            SizedBox(height: 8),
            Text("Business Hours: ${place.openingHours!.weekdayText.toList()}"),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Use this Business"),
              onPressed: () {
                // Save to Firestore or go to verification
              },
            ),
          ],
        ),
      ),
    );
  }
}
