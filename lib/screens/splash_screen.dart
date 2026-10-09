import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 20),
            const Text(
              'EcoTahu',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.darkGreen),
            ),
            const SizedBox(height: 10),
            const Text('Tahu Sehat, Lingkungan Kuat', style: TextStyle(color: AppTheme.textGrey)),
          ],
        ),
      ),
    );
  }
}