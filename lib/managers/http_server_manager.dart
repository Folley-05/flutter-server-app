// SPDX-FileCopyrightText: 2025 Benoit Rolandeau <benoit.rolandeau@allcircuits.com>
//
// SPDX-License-Identifier: MIT

import 'dart:convert';
import 'dart:io';

import 'package:esaip_lessons_server/data/server_constants.dart'
    as server_constants;
import 'package:esaip_lessons_server/managers/abstract_manager.dart';
import 'package:esaip_lessons_server/managers/global_manager.dart';
import 'package:esaip_lessons_server/managers/http_logging_manager.dart';
import 'package:esaip_lessons_server/models/http_log.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

/// This class is used to manage the http server
/// It will create a server and listen to the requests



class HttpServerManager extends AbstractManager {

    
  static const _api = "api";

  static const _version1 = "v1";

  static const _helloRoute = "hello";

  /// Instance of the http mobile app server
  late final HttpServer _mobileAppServer;

  /// Instance of the http things server
  late final HttpServer _thingsServer;

  /// Instance of the http logging manager
  late final HttpLoggingManager _httpLoggingManager;

  final List<House> _houses = [
  House(
    id: "house1",
    name: "Maison principale",
    isPowerOn: true,
    rooms: [
      Room(id: "room1", name: "Salon", imageOn: "salon_on.png", imageOff: "salon_off.png"),
      Room(id: "room2", name: "Cuisine", imageOn: "cuisine_on.png", imageOff: "cuisine_off.png"),
    ],
  ),
  House(
    id: "house2",
    name: "Maison secondaire",
    isPowerOn: false, // Électricité coupée
    rooms: [
      Room(id: "room3", name: "Chambre", imageOn: "chambre_on.png", imageOff: "chambre_off.png"),
    ],
  ),
];


  /// {@macro abstract_manager.initialize}
  @override
  Future<void> initialize() async {
    _httpLoggingManager = GlobalManager.instance.httpLoggingManager;

    final result = await Future.wait([
      _initServer(
        serverPort: server_constants.mobileAppServerPort,
        serverName: "Mobile App",
        initRoute: _initMobileAppRouter,
      ),
      _initServer(
        serverPort: server_constants.thingsServerPort,
        serverName: "Things App",
        initRoute: _initThingsAppRouter,
      ),
    ]);

    _mobileAppServer = result[0];
    _thingsServer = result[1];
  }

  /// Initialize the mobile app router
  Future<void> _initMobileAppRouter(Router app) async {
    app.get(formatVersion1Route(_helloRoute), _getHelloMobile);
    app.get(formatVersion1Route("test"), _testRoute);
    app.get(formatVersion1Route("temperature"), handleRequest);
    app.post(formatVersion1Route("houselist"), _getHouseList);
    app.post(formatVersion1Route("roomlist/<idHouse>"), _getRoomList);
  
  }

  /// Initialize the things app router
  Future<void> _initThingsAppRouter(Router app) async {
    app.get(formatVersion1Route(_helloRoute), _getHelloThing);
  }
  
  /// Initialize the server
  Future<HttpServer> _initServer({
    required int serverPort,
    required String serverName,
    required Future<void> Function(Router app) initRoute,
  }) async {
    final appRouter = Router();

    await initRoute(appRouter);

    final server = await io.serve(
      appRouter.call,
      server_constants.serverHostname,
      serverPort,
    );
    _httpLoggingManager.addLog(
      HttpLog.now(
        requestId: "server-start",
        route: '/',
        method: '/',
        logLevel: Level.info,
        message:
            'Server: $serverName started on ${server.address.host}:${server.port}',
      ),
    );

    return server;
  }


Future<Response> _getHouseList(Request request) async {
  final housesJson = _houses.map((h) => h.toJson()).toList();
  return Response.ok(jsonEncode(housesJson), headers: {'Content-Type': 'application/json'});
}

Future<Response> _getRoomList(Request request, String idHouse) async {
  final house = _houses.firstWhere((h) => h.id == idHouse, orElse: () => null);

  if (house == null) {
    return Response(404, body: jsonEncode({"error": "House not found"}), headers: {'Content-Type': 'application/json'});
  }

  if (!house.isPowerOn) {
    return Response(403, body: jsonEncode({"error": "Electricity is off in this house"}), headers: {'Content-Type': 'application/json'});
  }

  final roomsJson = house.rooms.map((r) => r.toJson()).toList();
  return Response.ok(jsonEncode(roomsJson), headers: {'Content-Type': 'application/json'});
}


// Petit helper pour route sans param

Handler _logRequestWrapper(Future<Response> Function(Request) handler) {
  return (Request request) => _logRequest(request, (requestId) async => handler(request));
}

  Future<Response> handleRequest(Request request) async {
    String strBody = await request.readAsString();
    dynamic body = null;
    try {
      body = jsonDecode(strBody);
	  /* 
	  Ici tu as récupéré le body donc tu peux faire tu traitement avec comme des calcul ou du crud
	   */
    } catch (e) {
      print("error on decoding the body");
    }
    print("the body $body");
    return body != null
        ? Response(
          200,
          body: jsonEncode(body),
          headers: {'Content-Type': 'application/json'},
        )
        // .ok(
        //   jsonEncode(body),
        //   headers: {'Content-Type': 'application/json'},
        // )
        : Response(
          403,
          body: jsonEncode({"error": "bad request"}),
          headers: {'Content-Type': 'application/json'},
        );
  }

  /// Route to handle the hello request
  Future<Response> _getHelloMobile(Request request) =>
      _logRequest(request, (requestId) async => handleRequest(request));
  Future<Response> _getHelloThing(Request request) => _logRequest(
    request,
    (requestId) async =>
        Response.ok('Hello, World! </br>From the thing server'),
  );
  Future<Response> _testRoute(Request request) => _logRequest(
    request,
    (requestId) async => Response.ok(
      "Welcome on test route !!! You gonna make amazing stuff with this route",
    ),
  );

  /// Useful method to wraps the request handling with logging
  Future<Response> _logRequest(
    Request request,
    Future<Response> Function(String requestId) handler,
  ) async {
    final requestId = shortHash(const Uuid().v1());

    _httpLoggingManager.addLog(
      HttpLog.now(
        requestId: requestId,
        route: request.requestedUri.toString(),
        method: request.method,
        logLevel: Level.info,
        message: "Received request",
      ),
    );
    final response = await handler(requestId);
    _httpLoggingManager.addLog(
      HttpLog.now(
        requestId: requestId,
        route: request.requestedUri.toString(),
        method: request.method,
        logLevel: Level.info,
        message: "Responded with status code ${response.statusCode}",
      ),
    );
    return response;
  }

  /// Close the given [server]
  Future<void> _closeServer(HttpServer server) async {
    _httpLoggingManager.addLog(
      HttpLog.now(
        requestId: "server-close",
        route: '/',
        method: '/',
        logLevel: Level.info,
        message: 'Server closed on ${server.address.host}:${server.port}',
      ),
    );
    await server.close(force: true);
  }

  /// Format the route for the server
  static String formatVersion1Route(String route) => '/$_api/$_version1/$route';

  /// {@macro abstract_manager.dispose}
  @override
  Future<void> dispose() async {
    await Future.wait([
      _closeServer(_mobileAppServer),
      _closeServer(_thingsServer),
    ]);
  }
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

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

}




 
 
