library json_rpc;

import 'dart:core';
import 'dart:async';
import 'dart:collection';
import 'dart:json' as JSON;
import 'dart:io';

/*
 * Client
 */
part 'client/rpc_client.dart';
part 'client/protocols/http_client_protocol.dart';
part 'client/protocols/http_client_user.dart';

/*
 * Server
 */
part 'server/rpc_server.dart';
part 'server/rpc_user.dart';
part 'server/rpc_protocol.dart';
// HTTP
part 'server/protocols/http/http_protocol.dart';
part 'server/protocols/http/http_user.dart';
// WebSocket
part 'server/protocols/websocket/websocket_protocol.dart';
part 'server/protocols/websocket/websocket_user.dart';


/*
 * Shared
 */
part 'rpc_request.dart';
part 'rpc_response.dart';
part 'rpc_error.dart';
