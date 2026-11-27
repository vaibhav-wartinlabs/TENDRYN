import 'package:get/get.dart';
import 'package:tendryn/core/api/api_exception.dart';
import 'package:tendryn/core/utils/app_logger.dart';

enum LoadStatus { idle, loading, success, error }

/// Loading / success / error state for any controller, with errors already
/// translated to a user-facing message.
mixin LoadableMixin on GetxController {
  final status = LoadStatus.idle.obs;
  final errorMessage = RxnString();

  Future<void> runLoad(Future<void> Function() task) async {
    status.value = LoadStatus.loading;
    errorMessage.value = null;
    try {
      await task();
      status.value = LoadStatus.success;
    } catch (e, st) {
      final error = ApiException.from(e);
      if (error.type == ApiErrorType.unexpected) AppLogger.error(e, st);
      errorMessage.value = error.message;
      status.value = LoadStatus.error;
    }
  }
}
