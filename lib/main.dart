import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v1/constants.dart';
import 'package:v1/emailauth/widget_tree.dart';
import 'package:v1/firebase_options.dart';
import 'package:v1/mobileauth/provider/auth_provider.dart';
import 'package:v1/screens/onboarding/onboarding_scrreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'ParkShare',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: bodyTextColor),
            bodySmall: TextStyle(color: bodyTextColor),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            contentPadding: EdgeInsets.all(defaultPadding),
            hintStyle: TextStyle(color: bodyTextColor),
          ),
        ),
        home: const WidgetTree(),
      ),
    );
  }
}


//LandingPage(email: 'hardik@123')