part of json_rpc;

class HttpServerConnector extends ServerConnector{
  
  HttpServer _server;
  
  HttpServerConnector(address, port) : super(address, port, false);
  
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
    HttpServerConnectorUser user = new HttpServerConnectorUser(this, req);
    
    _userConnectedController.add(user);
  }
  
  Future close() {
    Completer c = new Completer();
    _server.close();
    c.complete();
    return c.future;
  }
  
}