import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/notification_controller.dart';
import 'package:vehype/Controllers/offers_controller.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';
import '../Models/garage_model.dart';
import '../Models/offers_model.dart';
import 'loading_dialog.dart';

class OwnerAcceptOfferConfirmation extends StatefulWidget {
  const OwnerAcceptOfferConfirmation({
    super.key,
    required this.offersReceivedModel,
    required this.offersModel,
    required this.userModel,
    required this.chatId,
    required this.garageModel,
    required this.userController,
  });

  final OffersReceivedModel offersReceivedModel;
  final OffersModel offersModel;
  final UserModel userModel;
  final String? chatId;
  final GarageModel garageModel;
  final UserController userController;

  @override
  State<OwnerAcceptOfferConfirmation> createState() =>
      _OwnerAcceptOfferConfirmationState();
}

class _OwnerAcceptOfferConfirmationState
    extends State<OwnerAcceptOfferConfirmation> {
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 18)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
        onClosing: () {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        constraints: BoxConstraints(maxHeight: Get.height * 0.9),
        builder: (s) {
          return Container(
            width: Get.width,
            decoration: BoxDecoration(
              color: widget.userController.isDark ? primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "VEHYPE Terms of Use",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const SizedBox(height: 8),
                        _buildSectionTitle("1. Nature of the Platform"),
                        _buildBulletPoint(
                            "VEHYPE provides a digital marketplace for users to discover and communicate with independent automotive service providers."),
                        _buildBulletPoint(
                            "VEHYPE is not a service provider and does not supervise, guarantee, or take responsibility for services rendered."),
                        _buildBulletPoint(
                            "All service providers are independent parties. They are not employees, agents, or representatives of VEHYPE."),
                        _buildSectionTitle("2. User Responsibilities"),
                        _buildBulletPoint(
                            "Users are responsible for verifying the credentials, documentation, and insurance of any provider before agreeing to services."),
                        _buildBulletPoint(
                            "All interactions with providers occur at the user's discretion."),
                        _buildBulletPoint(
                            "VEHYPE recommends that users only engage with certified providers, who have insurance and documentation on file."),
                        _buildSectionTitle("3. Provider Responsibilities"),
                        _buildBulletPoint(
                            "Providers must agree to VEHYPE’s Code of Conduct and Service Quality Standards at registration."),
                        _buildBulletPoint(
                            "Certified providers are required to maintain active insurance documentation."),
                        _buildBulletPoint(
                            "Non-certified providers must upload valid government-issued identification and have a limited period to become certified."),
                        _buildBulletPoint(
                            "Non-certified providers failing to meet certification requirements may face account suspension."),
                        _buildSectionTitle("4. Payments and Subscriptions"),
                        _buildBulletPoint(
                            "VEHYPE does not facilitate or process payments for services. All financial transactions occur directly between users and providers."),
                        _buildBulletPoint(
                            "VEHYPE does not collect a commission. Instead, service providers subscribe to the platform via a monthly subscription fee."),
                        _buildBulletPoint(
                            "VEHYPE is not responsible for payment disputes, missed appointments, or cancellations. A community rating system is used to monitor service quality."),
                        _buildSectionTitle("5. Disputes and Reporting"),
                        _buildBulletPoint(
                            "Users and providers can report issues using VEHYPE’s in-app report feature."),
                        _buildBulletPoint(
                            "VEHYPE will investigate reported issues and provide supporting documentation when necessary."),
                        _buildBulletPoint(
                            "VEHYPE will not be liable for any service disputes. Users are encouraged to document all agreements and service terms independently."),
                        _buildSectionTitle("6. Communication and Moderation"),
                        _buildBulletPoint(
                            "VEHYPE provides an internal messaging system to facilitate user-provider communication."),
                        _buildBulletPoint(
                            "Messages may be flagged and reviewed if reported."),
                        _buildBulletPoint(
                            "VEHYPE does not tolerate harassment, fraud, or misuse of the communication system."),
                        _buildSectionTitle("7. Privacy and Data Protection"),
                        _buildBulletPoint(
                            "Access control via a secured SHA-256 authentication system."),
                        _buildBulletPoint(
                            "Encrypted storage for all user and vehicle data."),
                        _buildBulletPoint(
                            "Role-based permissions for backend operations."),
                        _buildBulletPoint(
                            "Location privacy protection (data is temporary and not permanently stored unless needed)."),
                        _buildBulletPoint(
                            "Use of HTTPS, rate limiting, and activity monitoring."),
                        _buildSectionTitle(
                            "8. Service Documentation and History"),
                        _buildBulletPoint(
                            "Providers must issue an estimate when offering a service. Upon completion, this estimate becomes an invoice."),
                        _buildBulletPoint(
                            "All invoices are saved to the repair history of both user and provider accounts and can be sent via email."),
                        _buildSectionTitle("9. Legal Disclaimer"),
                        _buildBulletPoint(
                            "VEHYPE is not responsible for the quality, legality, or safety of any service. All services are offered and accepted at the user’s own risk. VEHYPE's role is limited to facilitating discovery and communication."),
                        _buildBulletPoint(
                            "To the fullest extent permitted by law, no user shall bring any legal action or claim against VEHYPE for any property damage, physical injury, or financial loss resulting from use of the platform or services arranged through it."),
                        _buildBulletPoint(
                            "By using VEHYPE, all users agree that they are acting at their own risk and discretion."),
                        const SizedBox(height: 24),
                        const Text(
                          "By using VEHYPE, you acknowledge and accept these Terms of Use. These terms may be updated at any time. Continued use of the platform constitutes acceptance of any modifications.",
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.close(1);
                      },
                      child: Container(
                        height: 50,
                        width: Get.width * 0.42,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: widget.userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                            )),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        DocumentSnapshot<Map<String, dynamic>> offerByQuery =
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.offersReceivedModel.offerBy)
                                .get();
                        Get.close(1);

                        Get.dialog(LoadingDialog(), barrierDismissible: false);

                        OffersController().acceptOffer(
                            widget.offersReceivedModel,
                            widget.offersModel,
                            widget.userModel,
                            UserModel.fromJson(offerByQuery),
                            widget.chatId,
                            widget.garageModel);

                        NotificationController().sendNotification(
                            userIds: [UserModel.fromJson(offerByQuery).userId],
                            offerId: widget.offersModel.offerId,
                            requestId: widget.offersReceivedModel.id,
                            title: 'Good News: Offer Accepted',
                            subtitle:
                                '${widget.userController.userModel!.name} has accepted your offer. Tap here to review.');

                        OffersController().updateNotificationForOffers(
                            offerId: widget.offersModel.offerId,
                            userId: UserModel.fromJson(offerByQuery).userId,
                            senderId: widget.userController.userModel!.userId,
                            isAdd: true,
                            offersReceived: widget.offersReceivedModel.id,
                            checkByList: widget.offersModel.checkByList,
                            notificationTitle:
                                '${widget.userController.userModel!.name} has accepted your offer',
                            notificationSubtitle:
                                '${widget.userController.userModel!.name} has accepted your offer. Tap here to review.');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.userController.isDark
                            ? Colors.white
                            : primaryColor,
                        elevation: 1.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        maximumSize: Size(Get.width * 0.42, 50),
                        minimumSize: Size(Get.width * 0.42, 50),
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 17,
                          color: widget.userController.isDark
                              ? primaryColor
                              : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        });
  }
}
