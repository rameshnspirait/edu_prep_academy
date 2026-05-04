import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';

class ShareController extends GetxController {
  final String appLink =
      "https://play.google.com/store/apps/details?id=com.yourapp";

  void shareApp() {
    final message =
        '''
🚀 Crack Exams with Ease!

📚 Practice Mock Tests
📊 Track Your Performance
📥 Download Notes Offline

🔥 Join thousands of students now!

👉 Download Now:
$appLink
''';

    Share.share(message);
  }
}
