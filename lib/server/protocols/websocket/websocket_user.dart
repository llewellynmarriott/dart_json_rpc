part of json_rpc;

class WebSocketUser extends RpcUser {
  
  WebSocket ws;
  
  HashMap<dynamic, Completer> activeRequests = new HashMap<dynamic, Completer>();
  
  WebSocketUser(this.ws) {
   listen(); 
  }
  
  listen() {
    ws.listen((String data) {
      receiveData(data);
    }, cancelOnError: true);
  }
  
  
  Future sendData(String data) {
    Completer c = new Completer();
    ws.add(data);
    c.complete();
    return c.future;
  }
  
  Future close(String reason) {
    return ws.close().then((_){
      return super.close(reason); 
    });
  }
} 