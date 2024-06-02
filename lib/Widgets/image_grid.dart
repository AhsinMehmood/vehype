import 'package:flutter/material.dart';

class MasonryView extends StatelessWidget {
  final List<dynamic> listOfItem;
  final double itemPadding;
  final double itemRadius;
  final Widget Function(dynamic) itemBuilder;

  const MasonryView({
    super.key,
    required this.listOfItem,
    this.itemPadding = 4.0,
    this.itemRadius = 20,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: (listOfItem.length / 2).ceil(),
      itemBuilder: (BuildContext context, int index) {
        return Row(
          children: [
            _buildItem(index * 2),
            SizedBox(width: itemPadding), // Add spacing between items
            _buildItem(index * 2 + 1),
          ],
        );
      },
    );
  }

  Widget _buildItem(int index) {
    if (index >= listOfItem.length) {
      return SizedBox(); // Return empty SizedBox if index exceeds item count
    }
    final item = listOfItem[index];
    return Padding(
      padding: EdgeInsets.all(itemPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(itemRadius),
        child: itemBuilder(item),
      ),
    );
  }
}
