import 'dart:convert';
import 'dart:developer';

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:vehype/Controllers/vehicle_data.dart';

class AssistanceGuideAiService {
  final model =
      FirebaseVertexAI.instance.generativeModel(model: 'gemini-2.0-flash');
  Future<Map<String, dynamic>> repairCall(String prompt) async {
    List<String> services = [];

    for (var element in getServices()) {
      services.add(element.name);
    }

    final jsonSchema = Schema.object(
      properties: {
        'guide': Schema.object(
          properties: {
            'safety': Schema.string(),
            'tools': Schema.string(),
            'parts': Schema.string(),
            'services': Schema.enumString(enumValues: services),
            'steps': Schema.string(),
            'timeEstimate': Schema.string(),
            'considerations': Schema.string(),
            'sources': Schema.string(),
            'costEstimate': Schema.string(),
          },
        ),
      },
      optionalProperties: ['accessory'],
    );

    final response = await model.generateContent([
      Content.text(
          '$prompt: You are VEHYPE\'s assistant for vehicle repair guide. Should be short and consice'),
    ],
        generationConfig: GenerationConfig(
            responseMimeType: 'application/json', responseSchema: jsonSchema));

    String responseText = response.text!;
    try {
      final Map<String, dynamic> repairGuide = jsonDecode(responseText);
      // log('Repair Guide: ${repairGuide.toString()}');

      // Accessing the guide properties directly
      var guide = repairGuide['guide'];
      log('Safety: ${guide['safety']}');
      log('Tools: ${guide['tools']}');
      log('Parts: ${guide['parts']}');
      log('Services: ${guide['services']}');
      log('Steps: ${guide['steps']}');
      log('Time Estimate: ${guide['timeEstimate']}');
      log('Considerations: ${guide['considerations']}');
      log('Sources: ${guide['sources']}');
      log('Cost Estimate: ${guide['costEstimate']}');

      return guide;
    } catch (e) {
      log('Failed to parse JSON: $e');
      return {};
    }
  }
}
