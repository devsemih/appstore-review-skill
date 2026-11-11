import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'screens/auth_screen.dart';
import 'screens/rooms_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  Stripe.publishableKey = 'pk_live_EVALFIXTURE_publishable_0000';
  await Stripe.instance.applySettings();
  runApp(const HuddleApp());
}

class HuddleApp extends StatelessWidget {
  const HuddleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Huddle',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) =>
            snapshot.hasData ? const RoomsScreen() : const AuthScreen(),
      ),
    );
  }
}
