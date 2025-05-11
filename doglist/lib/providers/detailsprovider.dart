import 'dart:async';
import 'package:flutter/material.dart';

class DetailsProvider with ChangeNotifier {
  final PageController pageController = PageController(
    viewportFraction: 1.0, // Ensures one page is fully visible at a time
    keepPage: true, // Keeps the current page index when the widget tree rebuilds
  );
  int _currentPage = 0; // Current page index
  final Map<int, bool> _showError = {}; // Tracks error state for each image
  final Map<int, Timer?> _timers = {}; // Tracks timers for each image

  int get currentPage => _currentPage;

  void updatePage(int index) {
    _currentPage = index;
    _cancelAllTimers(); // Cancel all timers when the page changes
    notifyListeners(); // Notify listeners about the state change
  }

  bool showError(int index) => _showError[index] ?? false;

  void startErrorTimer(int index) {
    _timers[index]?.cancel(); // Cancel any existing timer for this index
    _timers[index] = Timer(const Duration(seconds: 10), () {
      _showError[index] = true; // Set error state after 10 seconds
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners(); // Notify listeners after the build phase
      });
    });
  }

  void cancelErrorTimer(int index) {
    _timers[index]?.cancel(); // Cancel the timer for this index
    _showError[index] = false; // Reset error state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners(); // Notify listeners after the build phase
    });
  }

  void _cancelAllTimers() {
    for (var timer in _timers.values) {
      timer?.cancel(); // Cancel all active timers
    }
    _timers.clear(); // Clear the timers map
  }

  @override
  void dispose() {
    pageController.dispose(); // Dispose the PageController
    _cancelAllTimers(); // Cancel all timers when disposing
    super.dispose();
  }
}
