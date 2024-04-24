// ProfileMenu.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:v1/constansts.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    Key? key,
    required this.value,
    required this.title,
    required this.icon1,
    this.icon2 = Iconsax.arrow_right_34,
  }) : super(key: key);

  final IconData icon1, icon2;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: IntrinsicHeight(
        child: Row(
          children: [
            Icon(icon1, size: 18),
            const SizedBox(width: 8), // Add space here
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: defaultPadding / 1.5,
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: bodyTextColor,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(icon2, size: 18),
          ],
        ),
      ),
    );
  }
}
