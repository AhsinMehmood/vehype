import 'dart:developer';

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/const.dart';
import 'package:vehype/providers/generate_photo_provider.dart';

import '../../providers/assistance_guide_ai_service.dart';

class AssistanceGuideUi extends StatefulWidget {
  final Map<String, dynamic>? repairGuide;
  const AssistanceGuideUi({
    super.key,
    required this.repairGuide,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AssistanceGuideUiState createState() => _AssistanceGuideUiState();
}

class _AssistanceGuideUiState extends State<AssistanceGuideUi> {
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        title: Text('Repair Guide'),
        leading: IconButton(
            onPressed: () {
              // for (var element in collection) {}
              Get.back();
            },
            icon: Icon(Icons.arrow_back_ios_new)),
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(6),
        children: [
          buildSection('Important Safety Precautions',
              widget.repairGuide?['safety'], Icons.warning_amber),
          buildSection(
              'Tools Required', widget.repairGuide?['tools'], Icons.build),
          buildSection(
              'Parts Required', widget.repairGuide?['parts'], Icons.lightbulb),
          buildSection('Step-by-Step Guide', widget.repairGuide?['steps'],
              Icons.directions_car),
          buildSection('Time Estimate', widget.repairGuide?['timeEstimate'],
              Icons.timer),
          buildSection('Cost Breakdown', widget.repairGuide?['costEstimate'],
              Icons.attach_money),
          buildSection('Final Considerations',
              widget.repairGuide?['considerations'], Icons.info_outline),
          buildSection(
              'Sources', widget.repairGuide?['sources'], Icons.info_outline),
        ],
      ),
    );
  }

// 1. Update buildSection to handle different data types
  Widget buildSection(String title, dynamic content, IconData icon) {
    final UserController userController = Provider.of<UserController>(context);

    if (content == null) return Container();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.5,
      color: userController.isDark ? primaryColor : Colors.white,
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: userController.isDark ? Colors.white : Colors.black,
            )),
        children: _buildContentChildren(content, title),
      ),
    );
  }

// 2. Create content handler method
  List<Widget> _buildContentChildren(dynamic content, String title) {
    if (title == 'Step-by-Step Guide') {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child:
              buildRepairSteps(content is List ? content.join('\n') : content),
        )
      ];
    }

    if (content is Map) {
      return content.entries
          .map((entry) => ListTile(
                leading:
                    const Icon(Icons.label_important, color: Colors.orange),
                title: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${entry.key}: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: entry.value.toString()),
                    ],
                  ),
                ),
              ))
          .toList();
    }

    if (content is List) {
      return content
          .map((item) => ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(item.toString()),
              ))
          .toList();
    }

    return [
      ListTile(
        leading: const Icon(Icons.info, color: Colors.blue),
        title: Text(content.toString()),
      )
    ];
  }

  Widget buildRepairSteps(String steps) {
    // Split lines to process each step
    List<String> lines = steps.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        // Detect titles wrapped in **
        if (line.contains('**')) {
          // Extract bold parts
          final regExp = RegExp(r'\*\*(.*?)\*\*');
          final matches = regExp.allMatches(line);
          List<TextSpan> spans = [];

          int lastMatchEnd = 0;
          for (var match in matches) {
            // Add regular text before match
            if (match.start > lastMatchEnd) {
              spans.add(TextSpan(
                text: line.substring(lastMatchEnd, match.start),
                // style: const TextStyle(color: Colors.black),
              ));
            }
            // Add bold text
            spans.add(TextSpan(
              text: match.group(1),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ));
            lastMatchEnd = match.end;
          }
          // Add remaining text after last match
          if (lastMatchEnd < line.length) {
            spans.add(TextSpan(
              text: line.substring(lastMatchEnd),
              style: const TextStyle(),
            ));
          }

          return RichText(
            text: TextSpan(
              children: spans,
              style: const TextStyle(fontSize: 16),
            ),
          );
        } else {
          // Regular text line
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          );
        }
      }).toList(),
    );
  }
}
