part of sni_http;

class WebsocketService {
  final String name;
  final String url;

  WebsocketService({
    required this.name,
    required this.url,
  }) {
    if (kDebugMode) {
      _controller.stream.listen((event) {
        final data = event;
        final String command = data['info'];
        if (!_listeners.contains(command)) {
          debugPrint('WEBSOCKET: UNHANDLED ${event.toString()}');
        }
      });
    }
  }

  WebSocketChannel? client;
  StreamSubscription? _clientSubscription;
  StreamSubscription? _heartbeat;

  ValueNotifier<bool> isConnected = ValueNotifier(false);

  Completer<bool> _connectionCompleter = Completer<bool>();
  Future<bool> get connected => _connectionCompleter.future;

  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  Timer? _heartbeatTimer;
  late DateTime _lastBeat;
  void _startHeartbeat() {
    _lastBeat = DateTime.now();
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      final diff = DateTime.now().difference(_lastBeat).inSeconds;
      if (diff < (15 * 3)) {
        write('user_check');
        return;
      }

      if (diff > (15 * 3)) {
        timer.cancel();
        client?.sink.close();
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
  }

  Future<void> open() async {
    try {
      isConnected.value = false;

      String? token;

      // final hasAuth = GetIt.I.isRegistered<AuthService>();
      // if (hasAuth) {
      //   final authService = GetIt.I<AuthService>();
      //   if (authService.isAccessTokenExpired) {
      //     await authService.refreshAccessToken();
      //   }

      //   token = authService.accessToken;
      // }

      final uri = Uri.parse('$url?token=$token');

      client = WebSocketChannel.connect(uri);
      _startHeartbeat();
      _clientSubscription = client?.stream.listen(
        (event) {
          try {
            isConnected.value = true;

            _lastBeat = DateTime.now();

            final data = json.decode(event);
            _controller.sink.add(data);
          } catch (e) {
            debugPrint(e.toString());
          }
        },
        onError: (err) {
          isConnected.value = false;
          debugPrint(err.toString());
        },
        onDone: () {
          isConnected.value = false;
          if (_connectionCompleter.isCompleted) {
            _connectionCompleter = Completer<bool>();
          }

          if (!_isDisposed) {
            Future.delayed(const Duration(seconds: 5), () async {
              await _clientSubscription?.cancel();
              await open();
            });
          }
        },
      );

      _heartbeat = when('user_check').listen((event) {
        write('user_check');
      });

      _connectionCompleter.complete(true);
    } catch (e) {
      if (!_isDisposed) {
        Future.delayed(const Duration(seconds: 5), open);
      }
    }
  }

  final _listeners = <String>[];
  Stream<T> when<T>(String info, {T Function(dynamic data)? transform}) {
    if (kDebugMode) {
      if (!_listeners.contains(info)) {
        _listeners.add(info);
      }
    }

    return _controller.stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          final String command = data['info'];
          if (command == info) {
            if (transform != null) {
              final value = transform(data);
              sink.add(value);
            } else {
              sink.add(data as T);
            }
          }
        },
        handleDone: (sink) {
          sink.close();
        },
        handleError: (error, stackTrace, sink) {
          sink.addError(error, stackTrace);
          sink.close();
        },
      ),
    );
  }

  Future<void> write(String command, {Map<String, dynamic>? data}) async {
    try {
      await connected;
      data ??= {};
      if (!data.containsKey('command')) {
        data['command'] = command;
      }

      final payload = json.encode(data);
      client?.sink.add(payload);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future writeAndWaitForResult(
    String command, {
    Map<String, dynamic>? data,
  }) async {
    await connected;

    final completer = Completer();
    late StreamSubscription sub;
    sub = when(command).listen((event) {
      completer.complete(event);
      sub.cancel();
      //_requestControllers.remove(command)?.close();
    });

    await write(command, data: data);
    return completer.future;
  }

  bool _isDisposed = false;
  void close() {
    _isDisposed = true;
    _stopHeartbeat();
    _heartbeat?.cancel();
    _clientSubscription?.cancel();
    client?.sink.close();

    _controller.close();
  }

  void dispose() {
    close();
  }
}
