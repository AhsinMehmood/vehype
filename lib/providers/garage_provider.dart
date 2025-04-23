import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../Models/garage_model.dart';

class GarageProvider with ChangeNotifier {
  List<GarageModel> _garages = [];
  List<GarageModel> get garages => _garages;

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> fetchGarages(String userId) async {
    try {
      // Run both queries in parallel
      final results = await Future.wait([
        FirebaseFirestore.instance
            .collection('garages')
            .where('ownerId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get(),
        FirebaseFirestore.instance
            .collection('garages')
            .where('deleteId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get(),
      ]);

      // Combine unique results
      final allDocs = {
        ...results[0].docs,
        ...results[1].docs,
      };

      _garages = allDocs.map((doc) => GarageModel.fromJson(doc)).toList();
      notifyListeners();
    } on FirebaseException catch (e) {
      print(e);

      _showError("Error fetching garages: ${e.message}");
    } catch (e) {
      print(e);
      _showError("Unexpected error: $e");
    }
  }

  /// Update a specific garage
  Future<void> updateGarage(
      String userId, GarageModel updatedGarage, String garageId) async {
    try {
      print(updatedGarage.garageId);
      await FirebaseFirestore.instance
          .collection('garages')
          .doc(garageId)
          .update(updatedGarage.toJson());

      // Update the local list
      fetchGarages(userId);
      notifyListeners();
    } on FirebaseException catch (e) {
      _showError("Error updating garage: ${e.message}");
    } catch (e) {
      _showError("Unexpected error: $e");
    }
  }

  Future<void> updateGarageImage(
      String userId, String garageId, String url) async {
    try {
      await FirebaseFirestore.instance
          .collection('garages')
          .doc(garageId)
          .update({
        'imageOne': url,
      });

      // Update the local list
      fetchGarages(userId);
      notifyListeners();
    } on FirebaseException catch (e) {
      _showError("Error updating garage: ${e.message}");
    } catch (e) {
      _showError("Unexpected error: $e");
    }
  }

  /// Delete a specific garage
  // Future<void> deleteGarage(String garageId) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('garages')
  //         .doc(garageId)
  //         .delete();

  // _garages.removeWhere((g) => g.garageId == garageId);
  //     notifyListeners();
  //   } on FirebaseException catch (e) {
  //     _showError("Error deleting garage: ${e.message}");
  //   } catch (e) {
  //     _showError("Unexpected error: $e");
  //   }
  // }

  /// Add a new garage
  Future<String> addGarage(GarageModel newGarage, String userId) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('garages')
          .add(newGarage.toJson());

      fetchGarages(userId);

      notifyListeners();
      return docRef.id;
    } on FirebaseException catch (e) {
      _showError("Error adding garage: ${e.message}");
      return '';
    } catch (e) {
      _showError("Unexpected error: $e");
      return '';
    }
  }
}
