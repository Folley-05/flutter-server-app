import 'dart:convert';
import 'dart:io';

/// path of the file to store sensors data
String filePath = './lib/store/sensor_data.json';

/// Stores the given data in a JSON file (appends to a list).
Future<void> writeDataToFile(Map<String, dynamic> data) async {
  final file = File(filePath);

  /// List of sensors
  List<dynamic> dataList = [];

  // If the file exists, read the current data
  if (await file.exists()) {
    String content = await file.readAsString();
    if (content.isNotEmpty) {
      try {
        dataList = jsonDecode(content) as List<dynamic>;
        if (dataList is! List) {
          dataList = []; // Ensure it's a list
        }
      } catch (e) {
        print('Error parsing JSON: $e');
      }
    }
  }

  // Append the new entry
  dataList.add(data);

  // Save the updated list
  await file.writeAsString(jsonEncode(dataList), mode: FileMode.write);
  print('Data saved successfully at: $filePath');
}

/// Retrieves all data from the JSON file.
Future<List<dynamic>> readAllData() async {
  final file = File(filePath);

  if (await file.exists()) {
    final String content = await file.readAsString();
    try {
      return jsonDecode(content) as List<dynamic>;
    } catch (e) {
      print('Error decoding JSON: $e');
      return [];
    }
  } else {
    print('No data file found at: $filePath');
    return [];
  }
}

/// Retrieves the last X entries from the JSON file.
Future<List<dynamic>> readLastEntries(int x) async {
  final List<dynamic> allData = await readAllData();
  return allData.isNotEmpty ? allData.takeLast(x) : [];
}

/// Extension method to take the last X elements from a list.
extension LastElements<T> on List<T> {
  List<T> takeLast(int count) {
    if (isEmpty) return [];
    return sublist(length - count < 0 ? 0 : length - count);
  }
}
