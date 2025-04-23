import 'dart:developer';

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';

class GeneratePhotoProvider with ChangeNotifier {
  String imagen = 'imagen-3.0-generate-002';

  Future<List<ImagenInlineImage>> generateImage(String query) async {
    try {
      // Initialize the model
      final model = FirebaseVertexAI.instance.imagenModel(model: imagen);

      // Generate content
      final response = await model.generateImages(
          'A highly detailed and realistic image of an $query. The focus is on the front of the vehicle.');

      // Extract and return the image URL
      if (response.images.isNotEmpty) {
        log(response.images.length.toString());
        return response.images;
      } else {
        print('No image URL returned.');
        return [];
      }
    } catch (e) {
      print('Error generating image: $e');
      return [];
    }
  }

// m
//
}
