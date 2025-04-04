import 'dart:convert';

import 'package:esaip_lessons_server/managers/sensor_manager.dart';
import 'package:esaip_lessons_server/models/sensor.dart';
import 'package:esaip_lessons_server/utils/file.dart';
import 'package:shelf/shelf.dart';

Future<Response> listSensors(Request request) async {
  List<Sensor> sensors = getSensors();
  return Response(
    200,
    body: jsonEncode(sensors.map((sensor) => sensor.toJson()).toList()),
    headers: {'Content-Type': 'application/json'},
  );
}

Future<Response> handleSensorData(Request request) async {
  String strBody = await request.readAsString();
  Map<String, dynamic> body;
  try {
    body = jsonDecode(strBody) as Map<String, dynamic>;
    await writeDataToFile(body);
    return Response(
      200,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    print("error on decoding the body $e");
    return Response(
      403,
      body: jsonEncode({"error": "bad request"}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

Future<Response> retrieveLastEntry(Request request) async {
  try {
    List<dynamic> lastEntry = await readLastEntries(1);
    return Response(
      200,
      body: jsonEncode(lastEntry),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    print("error on retrieving the data $e");
    return Response(
      501,
      body: jsonEncode({"error": "error on retrieving the data"}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
