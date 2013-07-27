part of json_rpc;

class WebSocketServerConnector extends ServerConnector{
  
  HttpServer _server;
  
  WebSocketServerConnector(address, port) : super(address, port, true);
  
  /*
   * Begins listening and handling connections.
   */
  Future listen() {
    return HttpServer.bind(address, port).then((HttpServer server) {
      this._server = server;
      return server.listen(_handleConnection);
    });
  }
  
  _handleConnection(HttpRequest req) {
    
    WebSocketTransformer.upgrade(req).then((WebSocket ws) {
      WebSocketServerConnectorUser user = new WebSocketServerConnectorUser(this, ws);
      _userConnectedController.add(user);
    });
   
  }
  
  Future close() {
    Completer c = new Completer();
    _server.close();
    c.complete();
    return c.future;
  }
  
}