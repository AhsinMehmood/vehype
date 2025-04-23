import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert';

class PhoneVerificationController with ChangeNotifier {
  final accountSid = 'AC25952d5ad27e50b313193a5b90b14b00';
  final authToken = '9e4a6dc17c7e4a5a0dbb2b9a4303e7e4';
  final serviceSid = 'VAd7807036655b201c408934048e721851';
  Future<int> sendOtp(String phoneNumber) async {
    final uri = Uri.parse(
        'https://verify.twilio.com/v2/Services/$serviceSid/Verifications');

    final response = await http.post(
      uri,
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'To': phoneNumber,
        'Channel': 'sms',
      },
    );

    if (response.statusCode == 201) {
      print('OTP sent!');
      return response.statusCode;
    } else {
      print('Failed to send OTP: ${response.body}');
      return response.statusCode;
    }
  }

  Future<int> verifyOtp(String phoneNumber, String code) async {
    final uri = Uri.parse(
        'https://verify.twilio.com/v2/Services/$serviceSid/VerificationCheck');

    final response = await http.post(
      uri,
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'To': phoneNumber,
        'Code': code,
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['status'] == 'approved') {
        print('OTP Verified!');
        return response.statusCode;
      } else {
        print('Incorrect OTP');
        return response.statusCode;
      }
    } else {
      print('Verification failed: ${response.body}');
      return response.statusCode;
    }
  }
}
