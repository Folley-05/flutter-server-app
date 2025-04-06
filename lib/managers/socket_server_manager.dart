import 'dart:io';

import 'package:esaip_lessons_server/utils/room.dart';

/// Function to handle socket communication
Future<Socket?> openSocket() async {
  final server = await ServerSocket.bind(InternetAddress.anyIPv4, 3500);
  print('Socket server is running on port ${server.port}');

  await for (final socket in server) {
    print(
      'New client connected: ${socket.remoteAddress.address}:${socket.remotePort}',
    );

    socket.listen(
      (data) async {
        final message = String.fromCharCodes(data).trim();
        print('Received: $message');
        final file = File('./lib/store/rooms.json');
        await file.writeAsString(message, mode: FileMode.write);
        print('Data saved successfully at: $filePath');

        // Echo back
        // socket.write('You said: $message\n');
      },
      onDone: () {
        print('Client disconnected');
        socket.destroy();
      },
      onError: (error) {
        print('Socket error: $error');
      },
    );
  return socket;
  }
  return null;
}
