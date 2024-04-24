// ProfileScreen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:v1/constansts.dart';
import 'package:v1/model/user_model.dart';
import 'package:v1/screens/home_screen.dart';
import 'package:v1/screens/onboarding/onboarding_scrreen.dart';
import 'package:v1/screens/profile/profile_menu.dart';
import 'package:v1/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    final UserModel userModel = ap.userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Profile',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage('assets/parksharelogo.png'),
                      radius: 60,
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    Text(
                      userModel.firstname,
                      style: const TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Jost-SemiBold',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: defaultPadding),
              const Divider(),
              const SizedBox(height: defaultPadding),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Personal information',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: 'SF Pro',
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding),
              ProfileMenu(
                title: 'First Name',
                value: userModel.firstname,
                icon1: Iconsax.profile_circle,
              ),
              ProfileMenu(
                title: 'Last Name',
                value: userModel.lastname,
                icon1: Iconsax.profile_circle,
              ),
              ProfileMenu(
                title: 'User Name',
                value: userModel.username,
                icon1: Iconsax.user_edit,
              ),
              ProfileMenu(
                title: 'Phone Number',
                value: userModel.phoneNumber,
                icon1: Iconsax.call,
              ),
              ProfileMenu(
                title: 'Date of Birth',
                value: userModel.dob.isNotEmpty
                    ? DateFormat.yMMMd().format(DateTime.parse(userModel.dob))
                    : 'Not Provided',
                icon1: Iconsax.calendar,
              ),
              const SizedBox(height: defaultPadding),
              const Divider(),
              const SizedBox(height: defaultPadding),
              Center(
                child: ElevatedButton(
                  onPressed: (

                  ) {
                     ap.userSignOut().then(
                          (value) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OnboardingScreen(),
                            ),
                          ),
                        );
                  },
                  child: const Text('Log Out'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
