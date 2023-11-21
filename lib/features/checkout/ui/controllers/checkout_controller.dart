part of '../checkout_screen.dart';

class CheckoutController with ChangeNotifier {
  final String choosenRules;

  CheckoutController(this.choosenRules);

  int _currentTagIndex = 0;
  int get currentTagIndex => _currentTagIndex;
  void setCurrentTagIndex(int index) {
    _currentTagIndex = index;
    notifyListeners();
  }

  ForumTags get currentForumTag => ForumTags.values[_currentTagIndex];

  String get rulesWithTag {
    final buffer = StringBuffer();

    buffer
      ..write('[${currentForumTag.closure}]\n')
      ..write('$choosenRules\n')
      ..write('[/${currentForumTag.closure}]')
      ..toString();

    return buffer.toString();
  }

  void sendChoosenRules() async {
    copyToClipboard(rulesWithTag).then(
      (_) async {
        if (kIsWeb ||
            (Platform.isAndroid &&
                await DeviceApps.isAppInstalled(
                    Constants.fourpdaClientPackageName))) {
          DeviceApps.openApp(Constants.fourpdaClientPackageName);
        } else {
          openUrl(Constants.fourpdaDefaultUrl);
        }
      },
    );
  }
}
