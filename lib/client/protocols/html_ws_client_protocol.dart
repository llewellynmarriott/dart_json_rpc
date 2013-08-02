part of json_rpc;

class HtmlWSClientProtocol extends RpcProtocol {
  
  WebSocketProtocol();
  
  Future listen(address, port) {}
  
  Future connectTo(String url) {
    Completer c = new Completer();
    c.complete(new HtmlWSClientUser(new WebSocket(url)));
    return c.future;
  }
  
  Future close() {
    Completer c = new Completer();
    c.complete();
    return c.future;
  }
  
}