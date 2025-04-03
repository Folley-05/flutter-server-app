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
}
