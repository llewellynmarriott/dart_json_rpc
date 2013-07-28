part of json_rpc;

class HttpClientProtocol extends RpcProtocol {
  
  HttpClientProtocol();
  
  /**
   * Begins listening and handling connections.
   */
  Future listen(dynamic address, int port) {}
  
  Future connectTo(String url) { 
    Completer c = new Completer(); 
    c.complete(new HttpClientUser(url));
    return c.future; 
  }
  
  _handleConnection(HttpRequest req) {}
  
  Future close() {
    Completer c = new Completer();

    c.complete();
    return c.future;
  }
  
}