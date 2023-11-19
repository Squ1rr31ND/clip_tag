import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../features/auth/ui/auth_screen.dart';
import '../features/auth/ui/controllers/auth_screen_controller.dart';
import '../features/auth/ui/email_verification_screen.dart';
import '../features/checkout/ui/checkout_screen.dart';
import '../features/forum_sections/ui/forum_sections_screen.dart';
import '../features/templates/ui/templates_screen.dart';
import '../shared/firebase_firestore_controller.dart';

Route<dynamic>? onGenerateRoute(RouteSettings settings) => MaterialPageRoute(
      builder: (context) => StreamBuilder(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return AuthScreenProvider(
              controller: AuthScreenController(),
              child: const AuthScreen(),
            );
          }

          if (snapshot.data?.emailVerified == false) {
            return const EmailVerificationScreen();
          }

          if (settings.name == TemplatesScreen.route) {
            return const TemplatesScreen();
          }

          if (settings.name == CheckoutScreen.route) {
            final rules = settings.arguments as String;
            return FirebaseFirestoreProvider(
              controller: FirebaseFirestoreController(),
              child: CheckoutScreen(choosenRules: rules),
            );
          }

          return const ForumSectionsScreen();
        },
      ),
    );
