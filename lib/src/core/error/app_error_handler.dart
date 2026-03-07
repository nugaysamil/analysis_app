import 'dart:developer' as dev;

// Centralized error handler for logging and wrapping async operations.
// Usage:
//   await AppErrorHandler.guard(() => someAsyncWork(), tag: 'ServiceName');
//   AppErrorHandler.log('Tag', error, stackTrace);
class AppErrorHandler {
  AppErrorHandler._();

  // Logs an error to the developer console with a class/service tag.
  static void log(String tag, Object error, [StackTrace? stack]) {
    dev.log(error.toString(), name: tag, error: error, stackTrace: stack);
  }
}
