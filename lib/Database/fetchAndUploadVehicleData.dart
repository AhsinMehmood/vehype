import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vehype/Widgets/loading_dialog.dart';

Future<void> fetchAndUploadVehicleData() async {
  final storage = FirebaseStorage.instance;
  final dir = await getTemporaryDirectory();
  final filePath = '${dir.path}/vehicles.jsonl';
  final file = File(filePath);
  final sink = file.openWrite();
  Get.dialog(LoadingDialog());
  final makesResponse = await http.get(Uri.parse(
      'https://vpic.nhtsa.dot.gov/api/vehicles/getallmakes?format=json'));
  final makesData = jsonDecode(makesResponse.body)['Results'];

  for (final make in makesData) {
    final makeName = make['Make_Name'];
    final makeId = make['Make_ID'];

    final jsonlEntry = jsonEncode({
      'make_id': makeId,
      'make': makeName,
    });

    sink.writeln(jsonlEntry);
    log(jsonlEntry);
  }

  await sink.flush();
  await sink.close();

  final uploadTask = await storage.ref('vehicles/vehicles.jsonl').putFile(file);
  final downloadUrl = await uploadTask.ref.getDownloadURL();
  Get.close(1);
  print("Uploaded to Firebase Storage at: $downloadUrl");
}
