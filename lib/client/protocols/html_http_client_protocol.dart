part of json_rpc;

class HtmlHttpClientProtocol extends RpcProtocol {
  
  HtmlHttpClientProtocol();
  
  Future listen(dynamic address, int port) {}
  
  Future connectTo(Uri uri) { 
    Completer c = new Completer(); 
    c.complete(new HtmlHttpClientUser(uri));
    return c.future; 
  }
  
  Future close() {
    Completer c = new Completer();

    c.complete();
    return c.future;
  }
  
}