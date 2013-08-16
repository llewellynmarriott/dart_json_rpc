part of json_rpc;

class WebSocketProtocol extends RpcProtocol {
  
  HttpServer httpServer;
  
  WebSocketProtocol();
  
  /*
   * Begins listening and handling connections.
   */
  Future listen(address, port) {
    return HttpServer.bind(address, port).then((HttpServer server) {
      this.httpServer = server;
      return server.listen(handleConnection);
    });
  }
  
  Future connectTo(String url) {
    return WebSocket.connect(url).then((WebSocket ws) {
      return new WebSocketUser(ws);
    });
  }
  
  handleConnection(HttpRequest req) {
    WebSocketTransformer.upgrade(req).then((WebSocket ws) {
      WebSocketUser user = new WebSocketUser(ws);
      userConnectedController.add(user);
    });
   
  }
  
  Future close() {
    Completer c = new Completer();
    server.close();
    c.complete();
    return c.future;
  }
  
}