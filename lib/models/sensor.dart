class Sensor {
  late String id;
  late String name;
  late String type;
  late Map<String, String> clientAttributes;
  late Map<String, String> serverAttributes;
  late Map<String, String> telemetryData;

  Sensor(
    this.id,
    this.name,
    this.type, {
    required this.clientAttributes,
    required this.serverAttributes,
    required this.telemetryData,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) => Sensor(
      json['id'] as String,
      json['name'] as String,
      json['type'] as String,
      clientAttributes: (json['clientAttributes'] as Map?)?.map(
            (key, value) => MapEntry(key as String, value as String),
          ) ??
          {},
      serverAttributes: (json['serverAttributes'] as Map?)?.map(
            (key, value) => MapEntry(key as String, value as String),
          ) ??
          {},
      telemetryData: (json['telemetryData'] as Map?)?.map(
            (key, value) => MapEntry(key as String, value as String),
          ) ??
          {},
    );

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'type': type,
      'clientAttributes': clientAttributes,
      'serverAttributes': serverAttributes,
      'telemetryData': telemetryData,
    };

  @override
  String toString() => 'Sensor{id: $id, name: $name, type: $type, '
        'clientAttributes: $clientAttributes, '
        'serverAttributes: $serverAttributes, '
        'telemetryData: $telemetryData}';
}
