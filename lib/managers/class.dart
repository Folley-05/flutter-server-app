// define rooom and methods
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
//  import 'package:esaip_lessons_server/managers/abstract_manager.dart';

// define room properties and methods
class Room {
  final String id;
  final String name;
  final String imageOn;
  final String imageOff;
  bool isOn;
// isOn is used to check if the room is on or off
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
// define house properties and methods 
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


