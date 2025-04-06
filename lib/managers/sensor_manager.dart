import 'package:esaip_lessons_server/models/sensor.dart';

/// Function to generate initial sensors
List<Sensor> getSensors() => [
    Sensor(
      "1",
      "Temperature Sensor On House",
      "temperature_sensor",
      clientAttributes: {'Serial Number': 'TS-001'},
      serverAttributes: {'Location': 'Living Room'},
      telemetryData: {'temperature': '22.5 °C'},
    ),
    Sensor(
      "2",
      "Domotic House ",
      "my_thing",
      clientAttributes: {'Serial Number': 'HS-002'},
      serverAttributes: {'Location': 'Kitchen'},
      telemetryData: {'temperature': '22.5 °C'},
    ),
  ];
