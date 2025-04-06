class Room {
  final String id;
  final String name;
  final String imageOn;
  final String imageOff;
  bool isOn;

  Room({
    required this.id,
    required this.name,
    required this.imageOn,
    required this.imageOff,
    this.isOn = false,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "imageOn": imageOn,
    "imageOff": imageOff,
    "isOn": isOn,
  };
}

class House {
  final String id;
  final String name;
  final bool isPowerOn;
  final List<Room> rooms;

  House({
    required this.id,
    required this.name,
    required this.isPowerOn,
    required this.rooms,
  });

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

