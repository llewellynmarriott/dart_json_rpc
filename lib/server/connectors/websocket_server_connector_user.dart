part of json_rpc;

class WebSocketServerConnectorUser extends RpcUser {
  
  WebSocket ws;
  
  HashMap<dynamic, Completer> activeRequests = new HashMap<dynamic, Completer>();
  
  WebSocketServerConnectorUser(ServerConnector connector, this.ws) : super(connector) {
   _listen(); 
  }
  
  _listen() {
    String buffer = "";
    
    ws.transform(new StringDecoder()).listen((String data) {
      buffer+=data;
    }, onDone: () {
      
      print('Server received: ' + buffer);
      // We don't know if the data received is a request or a response so we will try both.
      try {
        
        RpcRequest req = RpcRequest.fromJson(JSON.parse(buffer));
        req.user = this;
        // Send request back as data.
        _requestReceivedController.add(req);
        
      } catch(e) {
        print(e);
      }
      
      try {
        RpcResponse resp = RpcResponse.fromJson(JSON.parse(buffer));
        // Find matching id and complete the future.
        if(activeRequests.containsKey(resp.id)) {
          activeRequests[resp.id].complete(resp);
          activeRequests.remove(resp.id);
        } else {
          print('NO MATCHING ID D:');
        }
      } catch(e) {
        print(e);
      }
      
      
      
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
  
  Future respond(RpcResponse resp) {
    // Convert response to JSON and then write to client.
    String json = JSON.stringify(resp);
    
    ws.add(json);
    print('Server sent back: ' + json);
  }
  
  Future close() {
    return ws.close();
  }
} 