import 'package:esaip_lessons_server/models/sensor.dart';
import 'package:esaip_lessons_server/utils/functions.dart';

List<Sensor> getSensors() {
  return [
    Sensor(
      "1",
      "Temperature Sensor From Server",
      "temperature_sensor",
      clientAttributes: {'Serial Number': 'TS-001'},
      serverAttributes: {'Location': 'Living Room'},
      telemetryData: {'temperature': '22.5 °C'},
    ),
    Sensor(
      "2",
      "Humidity Sensor From Server",
      "my_thing",
      clientAttributes: {'Serial Number': 'HS-002'},
      serverAttributes: {'Location': 'Kitchen'},
      telemetryData: {'temperature': '22.5 °C'},
    ),
  ];
}

void receiveSensorData(dynamic data) {
	
}
