// ignore_for_file: avoid_print

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:xraychatboat/services/constants.dart';

class SocketService {
  late IO.Socket socket;

  void connect({required Function(Map<String, dynamic>) onNewChat}) {
    socket = IO.io(Constants.server, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Socket connected');
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
    });

    socket.onConnectError((error) {
      print('Connection error: $error');
    });

    socket.on('response', (data) {
      print('Received from socket: $data');
    });

    socket.on('newChat',(data){
      print('newChat: $data');
      onNewChat(Map<String, dynamic>.from(data));
    });
  }

  Future<void> sendChat(Map<String, dynamic> data) async{
    print(data);
    socket.emit('message', data);
  }

  void disconnect() {
    socket.disconnect();
  }
}
