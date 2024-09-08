// import 'package:flutter/material.dart';
// import 'package:media_picker_widget/media_picker_widget.dart';

// // Media;
// class MediaPickerSheet extends StatefulWidget {
//   final List<Media> mediaList;
//   const MediaPickerSheet({super.key, required this.mediaList});

//   @override
//   State<MediaPickerSheet> createState() => _MediaPickerSheetState();
// }

// class _MediaPickerSheetState extends State<MediaPickerSheet> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: MediaPicker(
//         mediaList: widget
//             .mediaList, //let MediaPicker know which medias are already selected by passing the previous mediaList
//         onPicked: (selectedList) {
//           print('Got Media ${selectedList.length}');
//         },
//         onCancel: () => print('Canceled'),
//         mediaCount: MediaCount.single,
//         mediaType: MediaType.image,
//         decoration: PickerDecoration(),
//       ),
//     );
//   }
// }
