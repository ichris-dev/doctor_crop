import 'package:agriconnect_v0/splash_screen.dart';
import 'package:agriconnect_v0/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const DoctorCropApp());
}

class DoctorCropApp extends StatelessWidget {
  const DoctorCropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Crop',
      debugShowCheckedModeBanner: false,
      theme: DoctorCropTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
