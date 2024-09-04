import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manage_calendar_events/manage_calendar_events.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/const.dart';

class CalendersList extends StatefulWidget {
  final List<Calendar> calenders;
  final OffersModel offersModel;
  final OffersReceivedModel offersReceivedModel;

  const CalendersList(
      {super.key,
      required this.calenders,
      required this.offersModel,
      required this.offersReceivedModel});

  @override
  State<CalendersList> createState() => _CalendersListState();
}

class _CalendersListState extends State<CalendersList> {
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = userController.userModel!;
    return Container(
      decoration: BoxDecoration(
        color: userController.isDark ? primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            'Select a Calendar To Add Event',
            style: TextStyle(
              color: userController.isDark ? Colors.white : primaryColor,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: widget.calenders.length,
                  // physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    Calendar calendar = widget.calenders[index];
                    return ListTile(
                      onTap: () async {
                        _addEvent(calendar.id ?? '');
                      },
                      title: Text(
                        calendar.accountName.toString(),
                        style: TextStyle(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }))
        ],
      ),
    );
  }

  void _addEvent(String calendarId) async {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    final UserModel userModel = userController.userModel!;
    Get.dialog(LoadingDialog(), barrierDismissible: false);
    DocumentSnapshot<Map<String, dynamic>> nameSnap = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(userModel.accountType == 'seeker'
            ? widget.offersModel.ownerId
            : widget.offersReceivedModel.offerBy)
        .get();

    UserModel secondUser = UserModel.fromJson(nameSnap);
    CalendarEvent newEvent = CalendarEvent(
      title: '${secondUser.name}: ${widget.offersModel.vehicleId}',
      description: widget.offersModel.issue,
      startDate: DateTime.parse(widget.offersReceivedModel.startDate).toLocal(),
      endDate: DateTime.parse(widget.offersReceivedModel.endDate).toLocal(),
      location: widget.offersModel.address,
      attendees: Attendees(
        attendees: [
          Attendee(emailAddress: secondUser.email, name: secondUser.name),
        ],
      ),
    );
    _myPlugin
        .createEvent(calendarId: calendarId, event: newEvent)
        .then((evenId) async {
      print(evenId);
      if (userModel.accountType == 'provider') {
        await FirebaseFirestore.instance
            .collection('offersReceived')
            .doc(widget.offersReceivedModel.id)
            .update({
          'seekerEventId': evenId,
          'seekerCalendarId': calendarId,
        });
      } else {
        await FirebaseFirestore.instance
            .collection('offersReceived')
            .doc(widget.offersReceivedModel.id)
            .update({
          'ownerEventId': evenId,
          'ownerCalendarId': calendarId,
        });
      }
    });

    Get.close(2);
    toastification.show(
        context: context,
        title: Text('Successfully Added to Calendar'),
        autoCloseDuration: Duration(seconds: 3));
  }

  final CalendarPlugin _myPlugin = CalendarPlugin();
}
