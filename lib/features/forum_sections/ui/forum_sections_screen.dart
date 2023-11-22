import 'package:flutter/material.dart';

import '../../../shared/constants.dart';
import '../../../shared/firebase/firebase_controller.dart';
import '../../../shared/ui/bbcode_renderer.dart';
import '../../../shared/ui/loading_circle.dart';
import '../../../shared/ui/show_snackbar.dart';
import '../../../utils/copy_to_clipboard.dart';
import '../../../utils/open_url.dart';
import '../../checkout/ui/checkout_screen.dart';
import '../../favorites/ui/favorites_screen.dart';
import '../data/model/forum_section_model.dart';
import '../domain/entity/forum_section.dart';
import '../utils/get_forum_section_icon.dart';

part 'controllers/sections_controller.dart';
part 'widgets/drawer.dart';
part 'widgets/end_drawer.dart';

class ForumSectionsScreen extends StatelessWidget {
  const ForumSectionsScreen({super.key});

  static const String route = '/forum_sections';

  @override
  Widget build(BuildContext context) {
    final firebase = FirebaseProvider.of(context);
    final controller = ForumSectionsController();
    final scrollController = ScrollController();

    final scaffoldKey = GlobalKey<ScaffoldState>();

    return WillPopScope(
      onWillPop: () async {
        if (scaffoldKey.currentState?.isDrawerOpen == true) {
          scaffoldKey.currentState?.closeDrawer();
          return false;
        }

        if (scaffoldKey.currentState?.isEndDrawerOpen == true) {
          scaffoldKey.currentState?.closeEndDrawer();
          return false;
        }

        if (controller.choosenRules.isNotEmpty) {
          controller.clearChoosenRules();
          return false;
        }

        if (controller.sectionIndex != 0) {
          controller.setSectionIndex(0);
          scrollController.jumpTo(0);
          return false;
        }

        return true;
      },
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, child) => Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            leading: controller.choosenRules.isNotEmpty
                ? IconButton(
                    onPressed: controller.clearChoosenRules,
                    icon: const Icon(Icons.close),
                  )
                : null,
            title: Text(
              controller.sections.isNotEmpty
                  ? controller.choosenRules.isNotEmpty
                      ? 'Подготовка тега'
                      : controller.section!.title
                  : 'ClipTag',
            ),
            actions: controller.choosenRules.isNotEmpty
                ? [
                    IconButton(
                      onPressed: () => controller.copyChoosenRules().then(
                        (_) {
                          showSnackbar(
                            context: context,
                            message: 'Скопировано в буфер обмена',
                          );
                          controller.clearChoosenRules();
                        },
                      ),
                      icon: const Icon(Icons.copy),
                    ),
                    IconButton(
                      onPressed: () => controller.navigateToCheckout(context),
                      icon: const Icon(Icons.send),
                    ),
                  ]
                : null,
            shadowColor: Colors.black,
            centerTitle: true,
          ),
          body: controller.sections.isNotEmpty
              ? ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: false,
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: controller.choosenRules.isNotEmpty
                        ? const EdgeInsets.only(bottom: 96.0)
                        : null,
                    children: [
                      for (final category in controller.section!.categories)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 1.0),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(category.title),
                              ),
                            ),
                            const Divider(height: 1.0),
                            for (final rule in category.rules)
                              ListTile(
                                title: BBCodeRenderer(rule),
                                onTap: !firebase.isUserAnonymous
                                    ? () => controller.choosenRules.isEmpty
                                        ? controller.navigateToCheckout(context,
                                            rule: rule)
                                        : controller.choosenRules.contains(rule)
                                            ? controller.removeRule(rule)
                                            : controller.addRule(rule)
                                    : null,
                                onLongPress: !firebase.isUserAnonymous &&
                                        controller.choosenRules.isEmpty
                                    ? () => controller.addRule(rule)
                                    : null,
                                tileColor:
                                    controller.choosenRules.contains(rule)
                                        ? Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer
                                        : null,
                              ),
                          ],
                        ),
                    ],
                  ),
                )
              : const LoadingCircle(),
          floatingActionButton: controller.choosenRules.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () => firebase
                      .addToFavorites(controller.mergeChoosenRules())
                      .then(
                    (_) {
                      controller.clearChoosenRules();
                      showSnackbar(
                        context: context,
                        message: 'Добавлено в избранное',
                      );
                    },
                  ),
                  icon: const Icon(Icons.bookmark_add),
                  label: Text(
                    'В избранное (${controller.choosenRules.length})',
                  ),
                )
              : null,
          drawer: const MainDrawer(),
          endDrawer: controller.sections.isNotEmpty
              ? MainEndDrawer(
                  sections: controller.sections,
                  sectionIndex: controller.sectionIndex,
                  onDestinationSelected: (index) {
                    controller.setSectionIndex(index);
                    controller.clearChoosenRules();
                    Navigator.pop(context);
                    scrollController.jumpTo(0);
                  },
                )
              : null,
        ),
      ),
    );
  }
}
