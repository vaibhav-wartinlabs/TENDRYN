import 'package:get/get.dart';

/// App-level startup work, run once from the splash screen before the first
/// real route. (The app is light-mode only, so there is no theme state here.)
class AppService extends GetxService {
  Future<void> initialize() async {}
}
