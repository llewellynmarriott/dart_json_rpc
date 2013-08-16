part of json_rpc;

class HtmlWSClientProtocol extends RpcProtocol {
  
  HtmlWSClientProtocol();
  
  Future listen(address, port) {}
  
  Future connectTo(String url) {
    Completer c = new Completer();
    var ws = new WebSocket(url);
    var client = new HtmlWSClientUser(ws);
    ws.onOpen.listen((_) {
      c.complete(client);
    });
    
    return c.future;
  }
  
  Future close() {
    Completer c = new Completer();
    c.complete();
    return c.future;
  }
  
}