part of json_rpc;

class WebSocketUser extends RpcUser {
  
  WebSocket ws;
  
  HashMap<dynamic, Completer> activeRequests = new HashMap<dynamic, Completer>();
  
  WebSocketUser(this.ws) {
   listen(); 
  }
  
  listen() {
    ws.listen((String data) {
      receiveJson(data);
    }, cancelOnError: true);
  }
  
  
  Future sendJson(String json) {
    Completer c = new Completer();
    ws.add(json);
    print('Sent: $json');
    c.complete();
    return c.future;
  }
  
  Future close() {
    return ws.close().then((_){
      return super.close(); 
    });
  }
} 