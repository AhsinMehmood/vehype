import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class GlobalErrorHandler {
  static String handleError(Exception error) {
    if (error is FirebaseException) {
      // Check if the exception is related to Firestore
      if (error.plugin == 'cloud_firestore') {
        return _handleFirestoreError(error);
      }
      return _handleFirebaseError(error);
    } else if (error is PlatformException) {
      return "A platform error occurred: ${error.message}";
    } else if (error is http.ClientException) {
      return "Network error: Please check your internet connection.";
    } else if (error is TimeoutException) {
      return "Request timed out. Please try again.";
    } else {
      return "Unexpected error: ${error.toString()}";
    }
  }

  static String _handleFirestoreError(FirebaseException error) {
    switch (error.code) {
      case 'not-found':
        return "The requested document does not exist.";
      case 'permission-denied':
        return "You do not have permission to access this data.";
      case 'unavailable':
        return "Firestore service is currently unavailable.";
      default:
        return "Firestore error: ${error.message}";
    }
  }

  static String _handleFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'network-request-failed':
        return "Network error: Please check your internet connection.";
      case 'unauthenticated':
        return "You need to sign in to access this feature.";
      default:
        return "Firebase error: ${error.message}";
    }
  }
}
