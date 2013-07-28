part of json_rpc;

class WebSocketProtocol extends RpcProtocol {
  
  HttpServer _server;
  
  WebSocketProtocol();
  
  /*
   * Begins listening and handling connections.
   */
  Future listen(address, port) {
    return HttpServer.bind(address, port).then((HttpServer server) {
      this._server = server;
      return server.listen(_handleConnection);
    });
  }
  
  Future connectTo(String url) {
    return WebSocket.connect(url).then((WebSocket ws) {
      return new WebSocketUser(ws);
    });
  }
  
  _handleConnection(HttpRequest req) {
    
    WebSocketTransformer.upgrade(req).then((WebSocket ws) {
      WebSocketUser user = new WebSocketUser(ws);
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