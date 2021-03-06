part of json_rpc;

class HtmlWSClientUser extends RpcUser {
  
  WebSocket ws;
  
  HashMap<dynamic, Completer> activeRequests = new HashMap<dynamic, Completer>();
  
  HtmlWSClientUser(this.ws) {
   ws.onMessage.listen(listen);
  }
  
  listen(MessageEvent e) {
    receiveData(e.data);
  }
  
  Future send(RpcRequest req) {
    Completer c = new Completer();
    
    // Add to our list of active requests so we can send back the response.
    activeRequests[req.id] = c;
    
    // Convert request to JSON and then write to client.
    String json = JSON.stringify(req);
    
    ws.send(json);
    
    return c.future;
  }
  
  Future sendData(String data) {
    Completer c = new Completer();
    ws.send(data);
    c.complete();
    return c.future;
  }
  
  Future close(String reason) {
    ws.close(1000, 'RPC closing connection');
    return super.close(reason);
  }
} 