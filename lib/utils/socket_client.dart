import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:meeting_app/networks/constants_network.dart';

//typedef of the event on socketIO
typedef void OnNewMessage(dynamic data);
typedef void OnNewLocation(dynamic data);
typedef void OnConnected(dynamic data);
typedef void OnJoined(dynamic data);
typedef void OnDisconnected(dynamic data);

//class to manage the socket connection and events
class SocketClient {
  // create the [SocketManager]
  final _manager = SocketIOManager();
  SocketIO _socket;
  OnNewMessage onNewMessage;
  OnConnected onConnected;
  OnJoined onJoined;
  OnDisconnected onDisconnected;
  OnNewLocation onNewLocation;

  //connect to the socket and manage the event
  connect(String room, String token) async {
    final options = SocketOptions(NetworkConstants.HOST, query: {"room": room, "token": token});

    _socket = await _manager.createInstance(options);

    await _socket.isConnected();

    _socket.on('connected', (data) {
      if (onConnected != null) {
        onConnected(data);
      }
    });

    _socket.on('joined', (data) {
      if (onJoined != null) {
        onJoined(data);
      }
    });

    _socket.on('disconnected', (data) {
      if (onDisconnected != null) {
        onDisconnected(data);
      }
    });

    _socket.on('new-message', (data) {
      if (onNewMessage != null) {
        onNewMessage(data);
      }
    });

    _socket.on('new-location', (data) {
      if (onNewLocation != null) {
        onNewLocation(data);
      }
    });

    _socket.onError((error) {
      print("on Error: ${error.toString()}");
    });

    _socket.connect();
  }

  emit(String eventName, dynamic data) {
    _socket.emit(eventName, [data]);
  }

  disconnect() async {
    await _manager.clearInstance(_socket);
  }
}
