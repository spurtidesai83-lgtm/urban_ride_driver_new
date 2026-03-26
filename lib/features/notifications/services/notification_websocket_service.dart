import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/notification_models.dart';
import '../../../shared/services/storage_service.dart';
import '../../../shared/config/api_config.dart';

class NotificationWebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _streamSubscription;
  final _notificationStreamController = StreamController<WebSocketNotification>.broadcast();
  bool _isConnecting = false;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  static const Duration _reconnectDelay = Duration(seconds: 5);
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  Stream<WebSocketNotification> get notificationStream => _notificationStreamController.stream;

  bool get isConnected => _isConnected;

  /// Connect to WebSocket
  Future<void> connect() async {
    if (_isConnected || _isConnecting) {
      print('📡 [WebSocket] Already connected or connecting');
      return;
    }

    _isConnecting = true;
    _reconnectAttempts = 0;

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        print('❌ [WebSocket] No authentication token found');
        _isConnecting = false;
        return;
      }

      final wsUrl = _buildWebSocketUrl(token);
      print('🔌 [WebSocket] Connecting to: $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Test connection
      await _channel!.ready;
      _reconnectAttempts = 0;
      _isConnected = true;
      _isConnecting = false;

      print('✅ [WebSocket] Connected successfully');

      // Listen for messages
      _streamSubscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );
    } catch (e) {
      print('❌ [WebSocket] Connection failed: $e');
      _isConnecting = false;
      _scheduleReconnect();
    }
  }

  /// Disconnect from WebSocket
  void disconnect() {
    print('📴 [WebSocket] Disconnecting...');
    _reconnectTimer?.cancel();
    _streamSubscription?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    _isConnecting = false;
  }

  /// Handle incoming messages
  void _onMessage(dynamic message) {
    try {
      print('📨 [WebSocket] Raw message: $message');

      // Parse JSON
      final jsonData = jsonDecode(message as String) as Map<String, dynamic>;

      // Create notification
      final notification = WebSocketNotification.fromJson(jsonData);

      print('✅ [WebSocket] Notification received: ${notification.topicDisplayName} - ${notification.message}');

      // Emit to stream
      _notificationStreamController.add(notification);
    } catch (e) {
      print('❌ [WebSocket] Error parsing message: $e');
    }
  }

  /// Handle WebSocket errors
  void _onError(dynamic error) {
    print('❌ [WebSocket] Error: $error');
    _isConnected = false;
    _scheduleReconnect();
  }

  /// Handle WebSocket done
  void _onDone() {
    print('📴 [WebSocket] Connection closed by server');
    _isConnected = false;
    _scheduleReconnect();
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('❌ [WebSocket] Max reconnection attempts reached');
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    print('⏰ [WebSocket] Scheduling reconnection (attempt $_reconnectAttempts/$_maxReconnectAttempts) in ${_reconnectDelay.inSeconds}s');

    _reconnectTimer = Timer(_reconnectDelay, () {
      if (!_isConnected) {
        connect();
      }
    });
  }

  /// Build WebSocket URL
  String _buildWebSocketUrl(String token) {
    // Convert https to ws, http to ws
    String baseUrl = ApiConfig.baseUrl;
    if (baseUrl.startsWith('https://')) {
      baseUrl = baseUrl.replaceFirst('https://', 'wss://');
    } else if (baseUrl.startsWith('http://')) {
      baseUrl = baseUrl.replaceFirst('http://', 'ws://');
    }

    // Remove trailing slash if present
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    final wsUrl = '$baseUrl/workshop/notifications?token=$token';
    return wsUrl;
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _notificationStreamController.close();
  }
}

final notificationWebSocketService = NotificationWebSocketService();
