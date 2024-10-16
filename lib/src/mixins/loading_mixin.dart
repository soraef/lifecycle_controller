import 'package:flutter/widgets.dart';

/// A mixin that provides loading state management for Flutter controllers.
///
/// The [LoadingMixin] helps manage loading states, making it easier to indicate when
/// an operation is in progress.
mixin LoadingMixin on ChangeNotifier {
  bool _isLoading = false;

  /// Indicates whether the controller is currently loading.
  bool get isLoading => _isLoading;

  String? _errorMessage;

  /// The current error message, if any.
  String? get errorMessage => _errorMessage;

  /// Returns `true` if an error has occurred.
  bool get isError => _errorMessage != null;

  /// Sets the controller to a loading state and notifies listeners.
  ///
  /// Use this method to indicate that a loading operation has started.
  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  /// Removes the loading state from the controller and notifies listeners.
  ///
  /// Use this method to indicate that a loading operation has completed.
  void endLoading() {
    _isLoading = false;
    notifyListeners();
  }

  /// Displays an error message and notifies listeners.
  ///
  /// [message] is the error message to display.
  ///
  /// Use this method to handle errors in asynchronous operations.
  void showError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clears the current error message and notifies listeners.
  ///
  /// Use this method to remove the error state after handling it.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Executes an asynchronous task with automatic loading and error handling.
  ///
  /// [task] is the asynchronous function to execute.
  ///
  /// This method will:
  /// - Set the loading state before starting the task.
  /// - Clear the loading state after the task completes.
  /// - If an error occurs, it will display the error message using [showError].
  ///
  /// If the controller is already in a loading state, the task will not be executed.
  ///
  /// ### Example
  ///
  /// ```dart
  /// await asyncRun(() async {
  ///   final data = await fetchData();
  ///   // Process data
  /// });
  /// ```
  Future<void> asyncRun(Future<String?> Function() task) async {
    if (isLoading) {
      return;
    }
    startLoading();
    try {
      final error = await task();
      if (error != null) {
        showError(error);
      }
    } catch (e) {
      showError(e.toString());
    } finally {
      endLoading();
    }
  }
}
