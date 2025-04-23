import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../Controllers/vehicle_data.dart';

class VehicleDataProvider with ChangeNotifier {
  static const String baseUrl = "https://vpic.nhtsa.dot.gov/api/vehicles";
  Future<void> addRandomServiceToRatings({required String ownerId}) async {
    try {
      // Reference to Firestore
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(ownerId);

      // Fetch current user data
      DocumentSnapshot userSnapshot = await userRef.get();

      if (!userSnapshot.exists) {
        print("User not found!");
        return;
      }

      // Extract current ratings list and ensure it's a list of maps
      List<dynamic> rawRatings =
          (userSnapshot.data() as Map<String, dynamic>)['ratings'] ?? [];

      // Ensure each entry is safely cast to a Map<String, dynamic>
      List<Map<String, dynamic>> currentRatings = rawRatings
          .whereType<
              Map<String, dynamic>>() // Ensures only valid maps are included
          .toList();
      // If there are no ratings, return early
      if (currentRatings.isEmpty) {
        print("No ratings found for this user.");
        return;
      }
      // Get a random service from getServices()
      List<Service> services = getServices();
      if (services.isEmpty) {
        print("No services available to assign.");
        return;
      }

      Service randomService = services[Random().nextInt(services.length)];

      // Update ratings list by adding a 'service' key to each rating if missing
      List<Map<String, dynamic>> updatedRatings = currentRatings.map((rating) {
        if (!rating.containsKey('service') || rating['service'] == null) {
          return {
            ...rating, // Ensure the existing data is preserved
            'service': randomService.name, // Assign random service
          };
        }
        return rating; // Keep unchanged if service already exists
      }).toList();

      // Update Firestore with the modified ratings
      await userRef.update({'ratings': updatedRatings});

      print(
          "Random service added to ratings successfully! ${randomService.name}");
    } catch (e) {
      print("Error updating ratings: $e");
    }
  }

  bool _isFetching = false;
  bool _isPaused = false;
  double _progress = 0.0;
  List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> _makes = [];
  int _currentIndex = 0;

  bool get isFetching => _isFetching;
  bool get isPaused => _isPaused;
  double get progress => _progress;
  List<Map<String, dynamic>> get data => _data;

  /// Helper function to make API requests with retry logic
  Future<http.Response?> _makeRequest(String url, {int retries = 3}) async {
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        final response =
            await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));
        if (response.statusCode == 200) return response;
        debugPrint(
            "⚠️ Attempt $attempt: API returned status ${response.statusCode}");
      } catch (e) {
        debugPrint("❌ Attempt $attempt: API request failed - $e");
      }
      await Future.delayed(Duration(seconds: 0)); // Wait before retrying
    }
    return null;
  }

  /// Fetch all vehicle makes
  Future<void> _fetchAllMakes() async {
    debugPrint("📡 Fetching vehicle makes...");
    final response = await _makeRequest("$baseUrl/GetAllMakes?format=json");
    if (response == null) {
      debugPrint("❌ Failed to fetch vehicle makes after retries.");
      return;
    }
    final data = jsonDecode(response.body);
    _makes = List<Map<String, dynamic>>.from(data['Results']);
    debugPrint("✅ Successfully fetched ${_makes.length} makes.");
  }

  /// Fetch models for a specific make
  Future<List<Map<String, dynamic>>> _fetchModels(String make) async {
    final response =
        await _makeRequest("$baseUrl/GetModelsForMake/$make?format=json");
    if (response == null) {
      debugPrint("⚠️ Failed to fetch models for $make.");
      return [];
    }
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['Results']);
  }

  /// Fetch vehicle types for a specific make ID
  Future<List<Map<String, dynamic>>> _fetchVehicleTypes(int makeId) async {
    final response = await _makeRequest(
        "$baseUrl/GetVehicleTypesForMakeId/$makeId?format=json");
    if (response == null) {
      debugPrint("⚠️ Failed to fetch vehicle types for Make_ID: $makeId.");
      return [];
    }
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['Results']);
  }

  /// Start fetching process with error handling
  Future<void> startFetching() async {
    if (_isFetching) return;

    debugPrint("🚀 Starting vehicle data fetch...");
    _isFetching = true;
    _isPaused = false;
    _progress = 0.0;
    _data.clear();
    _currentIndex = 0;
    notifyListeners();

    await _fetchAllMakes();
    if (_makes.isEmpty) {
      debugPrint("❌ No makes found, stopping process.");
      _isFetching = false;
      notifyListeners();
      return;
    }

    int totalMakes = _makes.length;

    while (_currentIndex < totalMakes && _isFetching) {
      if (_isPaused) {
        debugPrint("⏸️ Fetching paused...");
        await Future.delayed(Duration(milliseconds: 500));
        continue;
      }

      var make = _makes[_currentIndex];
      int makeId = make['Make_ID'];
      String makeName = make['Make_Name'];

      debugPrint("📡 Fetching data for: $makeName ($makeId)");

      try {
        final results = await Future.wait([
          _fetchModels(makeName),
          _fetchVehicleTypes(makeId),
        ]);

        _data.add({
          "Make_ID": makeId,
          "Make_Name": makeName,
          "Models": results[0],
          "VehicleTypes": results[1],
          "Years": List.generate(30, (i) => 1995 + i)
        });

        _progress = (_currentIndex + 1) / totalMakes;
        _currentIndex++;
        notifyListeners();

        debugPrint(
            "✅ Data fetched for: $makeName ($makeId) - Progress: ${(_progress * 100).toStringAsFixed(1)}%");
      } catch (e) {
        debugPrint("❌ Error processing $makeName: $e");
      }
    }

    if (_isFetching) {
      await _saveData();
      _isFetching = false;
      notifyListeners();
    }
  }

  /// Pause fetching process
  void pauseFetching() {
    _isPaused = true;
    debugPrint("⏸️ Fetching paused.");
    notifyListeners();
  }

  /// Resume fetching process
  void resumeFetching() {
    _isPaused = false;
    debugPrint("▶️ Fetching resumed.");
    notifyListeners();
  }

  /// Save data to a JSON file
  Future<void> _saveData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/vehicles.json');
      String jsonData = jsonEncode(_data);
      await file.writeAsString(jsonData);
      debugPrint("💾 Data saved to: ${file.path}");
    } catch (e) {
      debugPrint("❌ Failed to save data: $e");
    }
  }
}

class VehicleFetchScreen extends StatelessWidget {
  const VehicleFetchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fetch Vehicle Data')),
      body: Consumer<VehicleDataProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LinearProgressIndicator(
                  value: provider.progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 20),
                Text(
                  provider.isFetching
                      ? provider.isPaused
                          ? "Paused at ${(provider.progress * 100).toStringAsFixed(1)}%"
                          : "Fetching... ${(provider.progress * 100).toStringAsFixed(1)}%"
                      : "Press Start to Begin",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: provider.isFetching
                          ? null
                          : () => provider.startFetching(),
                      child: Text("Start"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: provider.isFetching && !provider.isPaused
                          ? () => provider.pauseFetching()
                          : null,
                      child: Text("Pause"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: provider.isFetching && provider.isPaused
                          ? () => provider.resumeFetching()
                          : null,
                      child: Text("Resume"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
