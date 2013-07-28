part of json_rpc;

class WebSocketUser extends RpcUser {
  
  WebSocket ws;
  
  HashMap<dynamic, Completer> activeRequests = new HashMap<dynamic, Completer>();
  
  WebSocketUser(this.ws) {
   _listen(); 
  }
  
  _listen() {
    ws.transform(new StringDecoder()).listen((String data) {
      _receiveJson(data);
    }, cancelOnError: true);
  }
  
  Future send(RpcRequest req) {
    Completer c = new Completer();
    
    // Add to our list of active requests so we can send back the response.
    activeRequests[req.id] = c;
    
    // Convert request to JSON and then write to client.
    String json = JSON.stringify(req);
    
    ws.add(json);
    
    return c.future;
  }
  
  Future _sendJson(String json) {
    Completer c = new Completer();
    ws.add(json.codeUnits);
    print('Sent: $json');
    c.complete();
    return c.future;
  }
  
  Future _closeConnection() {
    return ws.close();
  }
} 