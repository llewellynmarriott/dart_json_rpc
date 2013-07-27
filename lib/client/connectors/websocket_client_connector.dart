part of json_rpc;

class WebSocketClientConnector extends ClientConnector {
  
  // WebSocket for transfering data.
  WebSocket _ws;
  
  HashMap<dynamic, Completer> activeRequests = new HashMap<dynamic, Completer>();
  
  /**
   * Uses WebSockets to communicate between the client and the server.
   */
  WebSocketClientConnector(Uri uri) : super(uri, false);
  
  Future connect() {
    return WebSocket.connect(uri.toString()).then((WebSocket ws) {
      _ws = ws;
    });
  }
  
  /*
   * Sends a [RpcRequest] to the server and returns a [Future] that completers with a [RpcResponse].
   */
  Future send(RpcRequest req) {
    Completer c = new Completer();
    // Add to our list of active requests so we can send back the response.
    activeRequests[req.id] = c;
    // Convert request to JSON and then write to client.
    String json = JSON.stringify(req);
    
    _ws.add(json);
    
    return c.future;
  }
  
  _listen() {
    String buffer = "";
    
    _ws.transform(new StringDecoder()).listen((String data) {
      buffer+=data;
    }, onDone: () {
      
      print('Client received: ' + buffer);
      // We don't know if the data received is a request or a response so we will try both.
      try {
        
        RpcRequest req = RpcRequest.fromJson(JSON.parse(buffer));
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
          print('NO MATCHING ID (on client) D:');
        }
      } catch(e) {
        print(e);
      }
      
      
      
    }, cancelOnError: true);
  }
  
  Future close() {
    return _ws.close();
  }
}