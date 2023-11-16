import 'package:flutter/material.dart';

import '../features/auth/ui/auth_screen.dart';
import '../features/auth/ui/email_verification_screen.dart';
import '../features/checkout/ui/checkout_screen.dart';
import '../features/forum_sections/model/forum_section.dart';
import '../features/forum_sections/ui/forum_sections_screen.dart';
import '../features/rules/ui/rules_screen.dart';
import '../shared/constants.dart';
import '../shared/firebase_controller.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        onGenerateRoute: (RouteSettings settings) {
          final firebaseController = FirebaseController();

          return MaterialPageRoute(
            builder: (context) => FirebaseProvider(
              controller: firebaseController,
              child: StreamBuilder(
                stream: firebaseController.userChanges,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const AuthScreen();
                  }

                  if (snapshot.data?.emailVerified == false) {
                    return const EmailVerificationScreen();
                  }

                  switch (settings.name) {
                    case RulesScreen.route:
                      {
                        final forumSetion = settings.arguments as ForumSection;
                        return RulesScreen(forumSection: forumSetion);
                      }
                    case CheckoutScreen.route:
                      {
                        final rules = settings.arguments as dynamic;
                        return CheckoutScreen(choosenRules: rules);
                      }
                  }

                  return const ForumSectionsScreen();
                },
              ),
            ),
          );
        },
        title: Constants.appName,
        theme: ThemeData(
          useMaterial3: Constants.useMaterial3,
        ),
        darkTheme: ThemeData(
          useMaterial3: Constants.useMaterial3,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(color: Colors.black),
          navigationBarTheme: const NavigationBarThemeData(
            backgroundColor: Colors.black,
          ),
        ),
      );
}
