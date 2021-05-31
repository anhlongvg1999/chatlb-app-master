import 'dart:convert';

import 'package:chat_lb/model/messageModel.dart';
import 'package:chat_lb/model/socketResponse.dart';
import 'package:chat_lb/model/userModel.dart';
import 'package:chat_lb/service/appPrefs.dart';
import 'package:chat_lb/util/apiUrl.dart';
import 'package:chat_lb/util/string.dart';
import 'package:socket_io_client/socket_io_client.dart';

typedef OnReceiveMessage = void Function(bool, MessageModel);
typedef OnSocketMessage = void Function(SocketResponse);

class SocketService {
  static final SocketService _instance = new SocketService._internal();

  Socket _socket;

  factory SocketService.shared() {
    return _instance;
  }

  OnReceiveMessage _onReceiveMessage;

  set onReceiveMessage(OnReceiveMessage value) {
    _onReceiveMessage = value;
  }

  OnSocketMessage _onSocketMessage;

  set onSocketMessage(OnSocketMessage value) {
    _onSocketMessage = value;
  }

  SocketService._internal() {
    _socket = io(
        ApiURL.SOCKET,
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            .setExtraHeaders({}) // optional
            .build());

    _socket.onConnect((_) {
      print('connected');
      authentication();
    });
    _socket.onDisconnect((_) => print('disconnect'));
    _socket.on(Events.authentication, (data) => {print(data)});
    _socket.on(Events.receiveMessage, (data) {
      String jsonString = (data is List) ? jsonEncode(data.first) : jsonEncode(data);
      print(Events.receiveMessage + jsonString);
      final dataJson = jsonDecode(jsonString);
      _onReceiveMessage?.call(false, MessageModel.fromJson(dataJson));
    });
    _socket.on(Events.sendMessage, (data) {
      String jsonString = (data is List) ? jsonEncode(data.first) : jsonEncode(data);
      print(Events.sendMessage + jsonString);
      final dataJson = jsonDecode(jsonString);
      _onReceiveMessage?.call(true, MessageModel.fromJson(dataJson));
    });
    _socket.on(Events.confirmRegisterEmail, (data) {
      String jsonString =
          (data is List) ? jsonEncode(data.first) : jsonEncode(data);
      print(Events.confirmRegisterEmail + jsonString);
      final dataJson = jsonDecode(jsonString);
      _onSocketMessage?.call(SocketResponse.fromJson(dataJson));
    });

    _socket.on(Events.confirmChangeEmail, (data) {
      String jsonString =
      (data is List) ? jsonEncode(data.first) : jsonEncode(data);
      print(Events.confirmChangeEmail + jsonString);
      final dataJson = jsonDecode(jsonString);
      _onSocketMessage?.call(SocketResponse.fromJson(dataJson));
    });
  }

  Future<void> authentication() async {
    String token = await AppPrefs.share().getToken();
    UserModel currentUser = await AppPrefs.share().getCurrentUser();
    if (currentUser == null) {
      return;
    }
    if (token == null || token.isEmpty) {
      return;
    }
    if (currentUser.id == null || currentUser.id.isEmpty) {
      return;
    }
    String userId = currentUser.id;
    Map data = {'token': token, 'userId': userId};
    _emitMessage(Events.authentication, data);
  }

  void _emitMessage(String event, dynamic message) {
    if (!_socket.connected) {
      return;
    }
    print('emit: ' + jsonEncode(message));
    _socket.emit(event, message);
  }

  void sendMessage(dynamic message) {
    _emitMessage(Events.sendMessage, message);
  }

  void connect() {
    if (_socket.connected) {
      return;
    }
    _socket.connect();
  }

  void disconnect() {
    if (!_socket.connected) {
      return;
    }
    _socket.disconnect();
  }

  String getSocketId() {
    return _socket.id;
  }
}
