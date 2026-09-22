import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  ConnectivityService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity() {
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Stream<bool> get isConnectedStream => _controller.stream;

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final connected = results.any((result) => result != ConnectivityResult.none);
    _controller.add(connected);
  }

  Future<bool> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } catch (_) {
      return true; // Default to true if unable to check
    }
  }

  void dispose() {
    _controller.close();
  }
}
