part of json_rpc;

class WebSocketProtocol extends RpcProtocol {
  
  HttpServer httpServer;
  
  WebSocketProtocol();
  
  Future listen(address, port) {
    return HttpServer.bind(address, port).then((HttpServer server) {
      this.httpServer = server;
      server.listen(handleConnection);
    });
  }
  
  Future connectTo(Uri uri) {
    return WebSocket.connect(uri.toString()).then((WebSocket ws) {
      return new WebSocketUser(ws);
    });
  }
  
  void handleConnection(HttpRequest req) {
    try {
      WebSocketTransformer.upgrade(req).then((WebSocket ws) {
        WebSocketUser user;
        try {
          user = new WebSocketUser(ws);
          userConnectedController.add(user);
        } catch (e) {
          user.close('Handle error: ' + e);
        }
      });
    } catch (e) {
      print('Error with HttpRequest: ' + e);
      req.response.close();
    }
   
  }
  
  Future close() {
    Completer c = new Completer();
    server.close();
    c.complete();
    return c.future;
  }
  
}