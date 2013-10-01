part of json_rpc;

abstract class RpcUser {

  /**
   * StreamController that recieves data when the connection is closed.
   */
  StreamController connectionClosedController = new StreamController.broadcast();
  /**
   * StreamController that recieves data or error when a request is received.
   */
  StreamController requestReceivedController = new StreamController.broadcast();
  /**
   * StreamController that recieves data [RpcResponse] when an error is received.
   */
  StreamController errorReceivedController = new StreamController.broadcast();
  /**
   * All currently unreplied requests that have been received.
   */
  List<RpcRequest> receivedRequests = new List<RpcRequest>();
  /**
   * All currently unreplied requests that have been sent.
   */
  List<RpcRequest> sentRequests = new List<RpcRequest>();
  
  int currentId = 0;
  
  
  RpcUser();
  
  /**
   * Returns a [Stream] that will send back when the connection is closed.
   */
  Stream<RpcRequest> get connectionClosed => connectionClosedController.stream;
  /**
   * Returns a [Stream] that will send back data as an [RpcRequest] when a request is received from the client.
   */
  Stream<RpcRequest> get requestReceived => requestReceivedController.stream;
  /**
   * Returns a [Stream] that will send back data as an [RpcResponse] when a response with no ID is received from the server.
   */
  Stream<RpcResponse> get errorReceived => errorReceivedController.stream;
  
  /**
   * Sends an [RpcRequest] request and returns a Future that completes with a [RpcResponse] or completes with nothing if it is a notification (no ID set).
   */
  Future request(RpcRequest req) {
    
    if(!req.notification) {
      req.id = currentId;
      currentId++;
      sentRequests.add(req);
    }
    
    String json = JSON.stringify(req);
    sendJson(json);
    
    return req.responseReceivedCompleter.future;
  }
  
  /**
   * Sends an [RpcResponse] response back to the client, returns a Future that completes when the response has been sent.
   */
  Future respond(RpcResponse resp) {
    removeMatchingRequest(resp);
    String json = JSON.stringify(resp);
    sendJson(json);
  }
  
  /**
   * Removes the first [RpcRequest] from the received request list with matching ID to the [RpcRespnse].
   */
  void removeMatchingRequest(RpcResponse resp) {
    bool first = false;
    receivedRequests.removeWhere((RpcRequest req) {
      
      bool match = (req.id == resp.id && first == false);
      
      if(match) first = true;
      
      return match;
    });
  }
  
  /**
   * Must be called once data has been received from the endpoint.
   */
  void receiveJson(String json) {
    
    print('Receive JSON: $json');
    
    var obj;
    
    // Try to parse the JSON.
    try {
      obj = JSON.parse(json);
    } catch (e) {
      sendError(null, new RpcError(-32700, "Parse error", "An error occured on the server while parsing the JSON text."));
      return;
    }
    
    // Check if it's an array of requets or responses.
    if(obj is List) {
      for(var subObj in obj) {
        handleReceivedObject(subObj);
      }
    } else {
      handleReceivedObject(obj);
    }
    
  }
  
  /**
   * Checks that the received object has the correct parameters and determines whether or not it is a [RpcRequest] request or a [RpcResponse] response.
   */
  void handleReceivedObject(var json) {
    // Check RPC version
    if(json['jsonrpc'] != "2.0") {
      sendError(json['id'], new RpcError(-32603, "Internal error", "Unsupported protocol version."));
    } else {
      // If it has a method defined then it is a request.
      if(json['method'] != null) {
        handleRequestObject(json);
      } else if(json['result'] != null || json['error'] != null) {
        handleResponseObject(json);
      } else {
        sendError(json['id'], new RpcError(-32602, "Invalid request", "No method or result present."));
      }
    }
  }
  
  /**
   * Converts JSON into an [RpcRequest] and handles it.
   */
  void handleRequestObject(HashMap json) {
    // Check that 'params' is set.
    if(!json.containsKey('params')) {
      sendError(json['id'], new RpcError(-32600, "Invalid request", "No params present."));
    }
    
    RpcRequest req = RpcRequest.fromJson(json);
       
    req.user = this;
    // If its a notification we don't send a response, so no need to keep track of it.
    if(req.id != null) {
      receivedRequests.add(req);
    }
    
    requestReceivedController.add(req);
  }

  /**
   * Converts the JSON into an [RpcResponse] and handles it.
   */
  void handleResponseObject(var json) {
    RpcResponse resp = RpcResponse.fromJson(json);
    
    // Check if it's a notification
    if(resp.id == null) {
      errorReceivedController.add(resp);
      return ;
    }
    
    // Get first sent request with matching ID.
    RpcRequest match = sentRequests.firstWhere((RpcRequest req) {
      return req.id == resp.id;
    }, orElse: () { return null; });
    
    // If there was no matching ID then sent back an error.
    if(match == null) {
      sendError(null, new RpcError(-32602, "Invalid params", "No matching id: " + resp.id.toString()));
    } else {
      if(resp.error == null) {
        match.responseReceivedCompleter.complete(resp);
      } else {
        match.responseReceivedCompleter.completeError(resp.error);
      }
      sentRequests.remove(match);
    }
    
  }
  
  /**
   * Sends an error as a response to the endpoint.
   */
  void sendError(int id, RpcError error) {
    RpcResponse resp = new RpcResponse();
    resp.error = error;
    resp.id = id;
    
    String json = JSON.stringify(resp);
    sendJson(json);
  }
  
  /**
   * Sends back data as a JSON string.
   */
  Future sendJson(String json) {}
  
  /**
   * Replies to all active requests with a connection closing error and returns a Future that completes when all requests have been closed.
   * 
   * Code: -32001
   */
  Future close(String reason) {
    print("Closing: " + reason);
    List<Future> responses = [];
    try {
      for(RpcRequest req in receivedRequests) {
        responses.add(req.respondError(new RpcError(-32001, "Server error", "Connection closing.")));
      }     
    } catch (e) {}
    
    return Future.wait(responses).then((_) {
      connectionClosedController.add(null);
    });
  }

}