part of json_rpc;

class HttpClientProtocol extends RpcProtocol {
  
  HttpClientProtocol();
  
  /**
   * Begins listening and handling connections.
   */
  Future listen(dynamic address, int port) {}
  
  Future connectTo(Uri uri) { 
    Completer c = new Completer(); 
    c.complete(new HttpClientUser(uri));
    return c.future; 
  }
  
  Future close() {
    Completer c = new Completer();

    c.complete();
    return c.future;
  }
  
}