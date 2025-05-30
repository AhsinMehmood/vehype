import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:vehype/Pages/second_user_profile.dart';

import '../Models/user_model.dart';

class UserRatingShortWidget extends StatelessWidget {
  const UserRatingShortWidget({
    super.key,
    required this.secondUser,
  });

  final UserModel secondUser;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => SecondUserProfile(userId: secondUser.userId));
      },
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(200),
                child: CachedNetworkImage(
                  placeholder: (context, url) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                  imageUrl: secondUser.profileUrl,
                  height: 65,
                  width: 65,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: secondUser.isVerified ? 20 : null,
                  // width: 30,
                  decoration: BoxDecoration(
                      color: secondUser.isVerified
                          ? Colors.green.withOpacity(0.9)
                          : Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6)),
                  child: Center(
                    child: Text(
                      secondUser.isVerified ? 'VERIFIED' : 'NON\nVERIFIED',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: secondUser.isVerified ? 12 : 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                secondUser.name,
                style: TextStyle(
                  // color: Colors.black,

                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  RatingBarIndicator(
                    rating: secondUser.rating,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 20.0,
                    direction: Axis.horizontal,
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                '(${secondUser.ratings.length} Happy Customers)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Text(
                    'See Profile ',
                    style: TextStyle(
                      // color: Colors.black,

                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 16,
                    weight: 900.0,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
