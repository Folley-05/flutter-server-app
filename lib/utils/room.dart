import 'dart:convert';
import 'dart:io';

String filePath = './lib/store/rooms.json';

/// Stores the given data in a JSON file (appends to a list).
Future<void> writeRoomsToFile(List<Map<String, dynamic>> data) async {
  final file = File(filePath);
  print("going to write the rooms in the file");

  await file.writeAsString(jsonEncode(data), mode: FileMode.write);
  print('Data saved successfully at: $filePath');
}

/// Retrieves all data from the JSON file.
Future<String> readRoom() async {
  final file = File(filePath);

  if (await file.exists()) {
    final String content = await file.readAsString();
    try {
      return content;
    } catch (e) {
      print('Error decoding JSON: $e');
      return '';
    }
  } else {
    print('No data file found at: $filePath');
    return '';
  }
}