part of json_rpc;

abstract class RpcUser extends RpcMethodHandler {

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
  
  int _currentId = 1;
  
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
  
  
  Future request(String method, Object params) {
    return sendRequest(new RpcRequest(method, params));
  }
  
  void notify(String method, Object params) {
    sendRequest(new RpcRequest(method, params)
    ..id = null);
  }
  
  /**
   * Sends an [RpcRequest] request and returns a Future that completes with a [RpcResponse] or completes with nothing if it is a notification (no ID set).
   */
  Future sendRequest(RpcRequest req) {
    if(!req.notification) {
      req.id = _currentId;
      _currentId++;
      sentRequests.add(req);
    }
    
    _sendObject(req);
    
    return req.responseReceivedCompleter.future;
  }
  
  /**
   * Sends an [RpcResponse] response back to the client, returns a Future that completes when the response has been sent.
   */
  Future sendResponse(RpcResponse resp) {
    removeMatchingRequest(resp);
    _sendObject(resp);
  }
 
  
  /**
   * Sends an error as a response to the endpoint.
   */
  void sendError(int id, RpcError error) {
    RpcResponse resp = new RpcResponse();
    resp.error = error;
    resp.id = id;
    
    _sendObject(resp);
  }
  
  
  Future error(int code, String message, Object data) {
    return sendResponse(new RpcResponse()
    ..error = new RpcError(code, message, data));
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
  void receiveData(String data) {
    var json;
    // Try to parse the JSON.
    try {
      json = JSON.parse(data);
    } catch (e) {
      sendError(null, new RpcError(-32700, "Parse error", "An error occured on the server while parsing the JSON text."));
      // Close connection to prevent flooding, if for example the connection is to something that is not a JSON RPC server.
      close("An error occured on the server while parsing the JSON text.");
      return;
    }
    
    // Check if it's an array of requets or responses.
    if(json is List) {
      for(var subObj in json) {
        handleReceivedJson(subObj);
      }
    } else {
      handleReceivedJson(json);
    }
    
  }
  
  /**
   * Checks that the received object has the correct parameters and determines whether or not it is a [RpcRequest] request or a [RpcResponse] response.
   */
  void handleReceivedJson(HashMap json) {
    // Check RPC version
    if(json['jsonrpc'] != null && json['jsonrpc'] != "2.0") {
      sendError(json['id'], new RpcError(-32603, "Internal error", "Unsupported protocol version."));
    } else {
      // If it has a method defined then it is a request.
      if(json['method'] != null) {
        handleRequestJson(json);
      } else if(json['result'] != null || json['error'] != null) {
        handleResponseJson(json);
      } else {
        sendError(json['id'], new RpcError(-32602, "Invalid request", "No method or result present."));
      }
    }
  }
  
  /**
   * Converts JSON into an [RpcRequest] and handles it.
   */
  void handleRequestJson(HashMap json) {
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
  void handleResponseJson(HashMap json) {
    RpcResponse resp = RpcResponse.fromJson(json);
    resp.user = this;
    
    // Check if ID is null (response ID should not be null)
    if(resp.id == null) {
      error(-32602, "Invalid params", "No ID set.");
      close("No ID set.");
      return ;
    }
    
    // Get first sent request with matching ID.
    RpcRequest match = sentRequests.firstWhere((RpcRequest req) {
      return req.id == resp.id;
    }, orElse: () { return null; });
    
    // If there was no matching ID then sent back an error.
    if(match == null) {
      error(-32602, "Invalid params", "No matching id: " + resp.id.toString());
    } else {
      if(resp.error == null) {
        match.responseReceivedCompleter.complete(resp);
      } else {
        match.responseReceivedCompleter.completeError(resp.error);
      }
      sentRequests.remove(match);
    }
    
  }
  
  Future _sendObject(Object obj) {
    String json = JSON.stringify(obj);
    sendData(json);
  }
  
  /**
   * Sends back data as a JSON string.
   */
  Future sendData(String data);
  
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