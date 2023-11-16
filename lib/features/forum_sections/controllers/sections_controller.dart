import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../checkout/ui/checkout_screen.dart';
import '../model/forum_section.dart';

class ForumSectionsController with ChangeNotifier {
  final BuildContext context;

  ForumSectionsController({required this.context}) {
    FirebaseFirestore.instance.collection('rules').snapshots().listen(
          (query) => _setSections(query.docs
              .map((query) => ForumSection.fromJson(query.data()))
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order))),
        );
  }

  final List<ForumSection> _sections = [];
  void _setSections(List<ForumSection> sections) {
    if (_sections.isNotEmpty) {
      _sections.clear();
    }
    _sections.addAll(sections);
    notifyListeners();
  }

  List<ForumSection> get sections => _sections;
  ForumSection? get section => _sections[_sectionIndex];

  int _sectionIndex = 0;
  int get sectionIndex => _sectionIndex;
  void setSectionIndex(int index) {
    _sectionIndex = index;
    notifyListeners();
  }

  final _choosenRules = [];
  List get choosenRules => _choosenRules;

  void addRule(rule) {
    _choosenRules.add(rule);
    notifyListeners();
  }

  void removeRule(rule) {
    _choosenRules.remove(rule);
    notifyListeners();
  }

  void clearChoosenRules() {
    _choosenRules.clear();
    notifyListeners();
  }

  void navigateToCheckout({dynamic rule}) => Navigator.pushNamed(
        context,
        CheckoutScreen.route,
        arguments: section?.combineChoosenRulesToString(
          rule != null ? [rule] : _choosenRules,
        ),
      );
}
