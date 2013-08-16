part of json_rpc;

class HttpProtocol extends RpcProtocol {
  
  HttpServer _server;
  
  HttpProtocol();
  
  /**
   * Begins listening and handling connections.
   */
  Future listen(dynamic address, int port) {
    return HttpServer.bind(address, port).then((HttpServer server) {
      this._server = server;
      return server.listen(_handleConnection);
    });
  }
  
  Future connectTo(String url) {}
  
  _handleConnection(HttpRequest req) {
    HttpUser user = new HttpUser(req);
    
    userConnectedController.add(user);
  }
  
  Future close() {
    Completer c = new Completer();
    _server.close();
    c.complete();
    return c.future;
  }
  
}