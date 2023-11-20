import 'package:flutter/material.dart';

import '../../../shared/bbcode_renderer.dart';
import '../../../shared/constants.dart';
import '../../../shared/firebase_firestore_controller.dart';
import '../model/forum_tags.dart';
import 'controllers/checkout_controller.dart';
import 'widgets/forum_tag.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key, required this.choosenRules});

  static const String route = '/checkout';
  final String choosenRules;

  @override
  Widget build(BuildContext context) {
    final firestoreController = FirebaseFirestoreProvider.of(context);
    final checkoutController = CheckoutController(choosenRules);

    return ListenableBuilder(
      listenable: checkoutController,
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Подготовка тега'),
          actions: [
            IconButton(
              onPressed: checkoutController.copyChoosenRules,
              icon: const Icon(Icons.copy),
            ),
            IconButton(
              onPressed: checkoutController.switchTagVisibility,
              icon: Icon(
                checkoutController.isTagShown
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
            ),
            IconButton(
              onPressed: checkoutController.sendChoosenRules,
              icon: const Icon(Icons.send),
            ),
          ],
          shadowColor: Colors.black,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Constants.previewPadding),
            child: checkoutController.isTagShown
                ? ForumTag(
                    content: choosenRules,
                    tag: checkoutController.currentForumTag,
                  )
                : BBCodeRenderer(choosenRules),
          ),
        ),
        bottomNavigationBar:
            firestoreController.isModerator && checkoutController.isTagShown
                ? NavigationBar(
                    selectedIndex: checkoutController.currentTagIndex,
                    destinations: [
                      for (final tag in ForumTags.values)
                        NavigationDestination(
                            icon: Icon(tag.icon), label: tag.title),
                    ],
                    onDestinationSelected: (index) =>
                        checkoutController.setCurrentTagIndex(index),
                  )
                : null,
      ),
    );
  }
}
