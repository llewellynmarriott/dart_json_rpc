part of json_rpc;

class HtmlWSClientUser extends RpcUser {
  
  WebSocket ws;
  
  HashMap<dynamic, Completer> activeRequests = new HashMap<dynamic, Completer>();
  
  HtmlWSClientUser(this.ws) {
   ws.onMessage.listen(_listen);
  }
  
  _listen(MessageEvent e) {
    _receiveJson(e.data);
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
  
  Future _sendJson(String json) {
    Completer c = new Completer();
    ws.send(json);
    print('Sent: $json');
    c.complete();
    return c.future;
  }
  
  Future _closeConnection() {
    return ws.close();
  }
} 