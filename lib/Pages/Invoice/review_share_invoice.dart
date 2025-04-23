import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';

import 'package:vehype/Models/user_model.dart';

import 'package:vehype/const.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../../Controllers/pdf_generator.dart';

class ReviewShareInvoice extends StatefulWidget {
  final File pdfFile;
  final String invoiceNumber;
  const ReviewShareInvoice({
    super.key,
    required this.pdfFile,
    required this.invoiceNumber,
  });

  @override
  State<ReviewShareInvoice> createState() => _ReviewShareInvoiceState();
}

class _ReviewShareInvoiceState extends State<ReviewShareInvoice> {
  bool loading = false;
  // bool isLoadingPdf = true;
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = userController.userModel!;
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        elevation: 0.0,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
            )),
        centerTitle: true,
        title: Text(
          'Invoice #${widget.invoiceNumber}',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        color: userController.isDark ? primaryColor : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        // Get.dialog(LoadingDialog(), barrierDismissible: false);
                        // UserModel ownerModel
                        setState(() {
                          loading = true;
                        });

                        //                  if (isEmail) {
                        //   // Upload PDF to Firebase Storage
           
                        //   // String pdfUrl = await _uploadPDF(file);

                        //   // Call Cloud Function to send email
                        //   // log(currentUserEmail);
                        //   // log(pdfUrl);
                        await PDFGenerator.sendEmail(
                            widget.pdfFile, userModel.email);
                        setState(() {
                          loading = false;
                        });

                        //   await _sendEmail(file, currentUserEmail);
                        // } else {

                        // }
                        // Get.close(1);
                      },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(
                      color: userController.isDark
                          ? Colors.white.withOpacity(0.5)
                          : primaryColor.withOpacity(0.5),
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  minimumSize: Size(Get.width * 0.4, 50),
                ),
                child: loading
                    ? CupertinoActivityIndicator(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      )
                    : Text(
                        'Get via mail',
                        style: TextStyle(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              ElevatedButton(
                onPressed: () async {
                  OpenFile.open(widget.pdfFile.path);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  backgroundColor:
                      userController.isDark ? Colors.white : primaryColor,
                  minimumSize: Size(Get.width * 0.45, 50),
                  maximumSize: Size(Get.width * 0.45, 50),
                ),
                child: Text(
                  'Download',
                  style: TextStyle(
                    color: userController.isDark ? primaryColor : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: userController.isDark ? primaryColor : Colors.white,
          margin: const EdgeInsets.only(
            bottom: 100,
          ),
          child: PDFView(
            filePath: widget.pdfFile.path,
            backgroundColor:
                userController.isDark ? primaryColor : Colors.white,
            fitPolicy: FitPolicy.BOTH,
          ),
        ),
      ),
    );
  }
}
