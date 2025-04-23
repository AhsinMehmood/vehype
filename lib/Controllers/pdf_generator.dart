import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';
import 'package:get/get.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Widgets/select_date_and_price.dart';

import '../Models/offers_model.dart';
import '../Models/product_service_model.dart';

class PDFGenerator {
  static String getServiceDetail(ProductServiceModel prod) {
    if (prod.index == 0) {
      return '\$${double.parse(prod.pricePerItem).toStringAsFixed(2)}';
    } else if (prod.index == 1) {
      return '\$${prod.hourlyRate}';
    } else {
      return '\$${prod.flatRate}';
    }
  }

  static Future<Uint8List> _fetchNetworkImage(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception("Failed to load image");
    }
  }

  static String getQuantity(ProductServiceModel prod) {
    if (prod.index == 0) {
      return prod.quantity;
    } else if (prod.index == 1) {
      return prod.hours;
    } else {
      return '';
    }
  }

  // Cache the image locally
  static Future<void> _cacheImage(String url, Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${url.hashCode}.jpg';
    final file = File(filePath);

    await file.writeAsBytes(bytes);
  }

  // Get image from local cache (if available)
  static Future<Uint8List?> _getImageFromCache(String url) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${url.hashCode}.jpg';
    final file = File(filePath);

    if (await file.exists()) {
      return await file.readAsBytes();
    }

    return null;
  }

  static Future<File?> createInvoicePDF(
      {required OffersReceivedModel offersReceivedModel,
      required OffersModel offersModel,
      required UserModel onwerModel,
      required UserModel serviceModel,
      bool isEmail = false,
      String currentUserEmail = ''}) async {
    try {
      final pdf = pw.Document();
      Uint8List? imageBytes;
// if()/ await _getImageFromCache(serviceModel.profileUrl);
      imageBytes = await _getImageFromCache(serviceModel.profileUrl);
      imageBytes ??= await _fetchNetworkImage(serviceModel.profileUrl);
      // log(offersReceivedModel.createdAt);
      _cacheImage(serviceModel.profileUrl, imageBytes);
      final pw.MemoryImage networkImage = pw.MemoryImage(imageBytes);
      // String getAddressFr
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text("INVOICE",
                                style: pw.TextStyle(
                                    fontSize: 24,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 10),
                            pw.Text(serviceModel.name,
                                style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 5),
                            pw.Text(serviceModel.businessAddress),
                            pw.SizedBox(height: 5),
                            pw.Text(serviceModel.email),
                            pw.SizedBox(height: 5),
                            pw.Text(serviceModel.contactInfo),
                          ]),
                      pw.Column(children: [
                        pw.Image(networkImage, width: 100, height: 100),
                      ])
                    ]),
                pw.SizedBox(height: 20),
                pw.Text("Bill to",
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text(onwerModel.name),
                pw.Text(serviceModel.businessAddress),
                pw.SizedBox(height: 20),
                pw.Text("Invoice details",
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),

                pw.Text("Invoice no.: ${offersReceivedModel.randomId}"),
                pw.SizedBox(height: 10),

                // pw.Text("Terms: Net 30"),
                pw.Text(
                    "Invoice date: ${formatDate(DateTime.tryParse(offersReceivedModel.offerAt) ?? DateTime.now())}"),
                // pw.Text("Due date: 03/04/2025"),
                pw.SizedBox(height: 40),
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder(
                      // bottom: pw.BorderSide.none,
                      horizontalInside:
                          pw.BorderSide(width: 0.5, color: PdfColors.grey),
                      top: pw.BorderSide.none,
                      left: pw.BorderSide.none,
                      right: pw.BorderSide.none),
                  // columnWidths: {
                  //   0: pw.FlexColumnWidth(1),
                  //   1: pw.FlexColumnWidth(3),
                  //   2: pw.FlexColumnWidth(1),
                  //   3: pw.FlexColumnWidth(1),
                  //   4: pw.FlexColumnWidth(1),
                  //   // 5: pw.FlexColumnWidth(1),
                  // },
                  headers: [
                    "#",
                    // "Date",
                    "Product or service",
                    "Description",

                    "Qty         ",
                    "Rate      ",
                    "Amount     "
                  ],
                  data: offersReceivedModel.products
                      .map((product) => [
                            "1", // You might need to replace this with `product.id`
                            product.name,
                            product.desc,

                            getQuantity(product),
                            getServiceDetail(product),
                            '\$${product.totalPrice}',
                          ])
                      .toList(),
                ),
                pw.SizedBox(height: 40),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      children: [
                        // pw.Text("Ways to pay",
                        //     style: pw.TextStyle(
                        //         fontSize: 16,
                        //         fontWeight: pw.FontWeight.bold,
                        //         color: PdfColors.blue)),
                        // pw.SizedBox(height: 40),
                        // pw.Container(
                        //     decoration: pw.BoxDecoration(
                        //       borderRadius: pw.BorderRadius.circular(12),
                        //       color: PdfColors.blue,
                        //     ),
                        //     padding: pw.EdgeInsets.all(12),
                        //     width: 140,
                        //     child: pw.Center(
                        //       child: pw.Text("View and pay",
                        //           style: pw.TextStyle(
                        //             color: PdfColors.white,
                        //             fontSize: 17,
                        //             fontWeight: pw.FontWeight.bold,
                        //           )),
                        //     ))
                      ],
                    ),
                    pw.Expanded(
                        child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.SizedBox(width: 1),
                        pw.Column(
                          children: [
                            // pw.Text("Subtotal:  "),
                            // pw.SizedBox(height: 5),
                            // pw.Container(
                            //   height: 0.5,
                            //   width: 100,
                            //   color: PdfColors.grey, // ✅ Standard grey color
                            // ),
                            pw.SizedBox(height: 10),
                            // pw.Text("Sales tax: "),
                            // pw.SizedBox(height: 10),

                            pw.SizedBox(height: 20),
                            pw.Text("Total: ",
                                style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 5),
                          ],
                        ),
                        pw.Column(
                          children: [
                            // pw.Text('\$${offersReceivedModel.price}'),
                            // pw.SizedBox(height: 5),
                            // pw.Container(
                            //   height: 0.5,
                            //   width: 100,
                            //   color: PdfColors.grey, // ✅ Standard grey color
                            // ),
                            pw.SizedBox(height: 10),
                            // pw.Text("\$0.47"),
                            // pw.SizedBox(height: 10),
                            // pw.Container(
                            //   height: 0.5,
                            //   width: 100,
                            //   color: PdfColors.grey, // ✅ Standard grey color
                            // ),
                            pw.SizedBox(height: 20),
                            pw.Text("\$${offersReceivedModel.price}",
                                style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 5),
                            pw.Container(
                              height: 0.5,
                              width: 100,
                              color: PdfColors.grey, // ✅ Standard grey color
                            ),
                          ],
                        ),
                      ],
                    ))
                  ],
                ),
              ],
            );
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      print(directory.path);

      final file = File(
          "${directory.path}/invoice #${offersReceivedModel.randomId}.pdf");
      print(file.path);
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      log(e.toString());

      return null;
    }
  }

  static Future<void> sendEmail(File pdf, String recipientEmail) async {
    // final functions = FirebaseFunctions.instance;
    try {
      String username = 'developera574@gmail.com';
      String password = 'ozcriypjmnmmslox';
      final smtpServer = gmail(username, password);
      final equivalentMessage = Message()
        ..from = Address(username, 'VEHYPE')
        ..recipients.add(Address(recipientEmail))
        // ..ccRecipients.addAll([Address('destCc1@example.com'), 'destCc2@example.com'])
        // ..bccRecipients.add('bccAddress@example.com')
        ..subject = 'Your Invoice from VEHYPE'
        ..text =
            'Hello,\n\nAttached is your invoice from VEHYPE.\n\nBest Regards,\nVEHYPE Team'
        // ..html =
        //     '<h1>Test</h1>\n<p>Hey! Here is some HTML content</p><img src="cid:myimg@3.141"/>'
        ..attachments = [FileAttachment(pdf)];
      await send(equivalentMessage, smtpServer);
      // sendReport2.
      // await connection.close();
      // print("✅ Email sent successfully!");
      Get.showSnackbar(GetSnackBar(
        message: '✅ Email sent successfully!',
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      ));
    } catch (e) {
      Sentry.captureMessage(e.toString());
      // print("🔥 Error calling sendPDFEmail: $e");
      Get.showSnackbar(GetSnackBar(
        message: '❌ Failed to send email',
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      ));
      // print("❌ Failed to send email:");
    }
  }

  static Future<void> sendEmailForReport(
    UserModel reportedBy,
    UserModel reportTo,
    OffersReceivedModel offersReceivedModel,
    OffersModel offersModel,
    String feedbackId,
    UserController userController,
    String feedback,
    String rating,
  ) async {
    // final functions = FirebaseFunctions.instance;
    try {
      String username = 'developera574@gmail.com';
      String password = 'ozcriypjmnmmslox';
      final smtpServer = gmail(username, password);
      PackageInfo appInfo = await PackageManager.getPackageInfo();
      final equivalentMessage = Message()
        ..from = Address(username, 'VEHYPE (Beta)')
        ..recipients.addAll(
          userController.adminsEmails.map((email) => Address(email)),
        )
        ..subject = 'Private Feedback – ${reportedBy.name}'
        ..text = '''
${reportedBy.name} submitted a report.

**Feedback:**

$feedback


**Rating:**

$rating

**Report ID:**

$feedbackId



You can manage reports by going to:
VEHYPE app > Profile > Manage Reports

Best regards,
VEHYPE Support Team


**App Info:**
${const JsonEncoder.withIndent('  ').convert(appInfo.toJson())}



*This is an automated message from the VEHYPE beta system*
''';
      await send(equivalentMessage, smtpServer);
      // sendReport2.
      // await connection.close();
      // print("✅ Email sent successfully!");
      Get.showSnackbar(GetSnackBar(
        message: '✅ Feedback submitted successfully!',
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      ));
    } catch (e) {
      Sentry.captureMessage(e.toString());
      // print("🔥 Error calling sendPDFEmail: $e");
      // Get.showSnackbar(GetSnackBar(
      //   message: '❌ Failed to send email',
      //   duration: Duration(seconds: 3),
      //   snackPosition: SnackPosition.TOP,
      // ));
      // print("❌ Failed to send email:");
    }
  }
}

