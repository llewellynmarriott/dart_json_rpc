part of json_rpc;

abstract class RpcUser {

  /**
   * StreamController that recieves data or error when a request is received.
   */
  StreamController _requestReceivedController = new StreamController.broadcast();
  /**
   * StreamController that recieves data [RpcResponse] when an error is received.
   */
  StreamController _errorReceivedController = new StreamController.broadcast();
  /**
   * All currently unreplied requests that have been received.
   */
  List<RpcRequest> receivedRequests = new List<RpcRequest>();
  /**
   * All currently unreplied requests that have been sent.
   */
  List<RpcRequest> sentRequests = new List<RpcRequest>();
  
  int _currentId = 0;
  
  
  RpcUser();
  
  /**
   * Returns a [Stream] that will send back data as an [RpcRequest] when a request is received from the client.
   */
  Stream<RpcRequest> get requestReceived => _requestReceivedController.stream;
  /**
   * Returns a [Stream] that will send back data as an [RpcResponse] when a response with no ID is received from the server.
   */
  Stream<RpcResponse> get errorReceived => _errorReceivedController.stream;
  
  /**
   * Sends an [RpcRequest] request and returns a Future that completes with a [RpcResponse] or completes with nothing if it is a notification (no ID set).
   */
  Future request(RpcRequest req) {
    
    if(!req.notification) {
      req.id = _currentId;
      _currentId++;
      sentRequests.add(req);
    }
    
    String json = JSON.stringify(req);
    _sendJson(json);
    
    return req.responseReceivedCompleter.future;
  }
  
  /**
   * Sends an [RpcResponse] response back to the client, returns a Future that completes when the response has been sent.
   */
  Future respond(RpcResponse resp) {
    _removeMatchingRequest(resp);
    String json = JSON.stringify(resp);
    _sendJson(json);
  }
  
  /**
   * Removes the first [RpcRequest] from the received request list with matching ID to the [RpcRespnse].
   */
  void _removeMatchingRequest(RpcResponse resp) {
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
  void _receiveJson(String json) {
    
    print('Receive JSON: $json');
    
    var obj;
    
    // Try to parse the JSON.
    try {
      obj = JSON.parse(json);
    } catch (e) {
      _sendError(null, new RpcError(-32700, "Parse error", "An error occured on the server while parsing the JSON text."));
      return;
    }
    
    // Check if it's an array of requets or responses.
    if(obj is List) {
      for(var subObj in obj) {
        _handleReceivedObject(subObj);
      }
    } else {
      _handleReceivedObject(obj);
    }
    
  }
  
  /**
   * Checks that the received object has the correct parameters and determines whether or not it is a [RpcRequest] request or a [RpcResponse] response.
   */
  void _handleReceivedObject(var json) {
    // Check RPC version
    if(json['jsonrpc'] != "2.0") {
      _sendError(json['id'], new RpcError(-32603, "Internal error", "Unsupported protocol version."));
    }
    
    // If it has a method defined then it is a request.
    if(json['method'] != null) {
      _handleRequestObject(json);
    } else if(json['result'] != null || json['error'] != null) {
      _handleResponseObject(json);
    } else {
      _sendError(json['id'], new RpcError(-32602, "Invalid request", "No method or result present."));
    }
  }
  
  /**
   * Converts JSON into an [RpcRequest] and handles it.
   */
  void _handleRequestObject(var json) {
    // Check that 'params' is set.
    if(json['params'] == null) {
      _sendError(json['id'], new RpcError(-32600, "Invalid request", "No params present."));
    }
    
    RpcRequest req = RpcRequest.fromJson(json);
       
    req.user = this;
    // If its a notification we don't send a response, so no need to keep track of it.
    if(req.id != null) {
      receivedRequests.add(req);
    }
    
    _requestReceivedController.add(req);
  }

  /**
   * Converts the JSON into an [RpcResponse] and handles it.
   */
  void _handleResponseObject(var json) {
    RpcResponse resp = RpcResponse.fromJson(json);
    
    // Check if it's a notification
    if(resp.id == null) {
      _errorReceivedController.add(resp);
      return ;
    }
    
    // Get first sent request with matching ID.
    RpcRequest match = sentRequests.firstWhere((RpcRequest req) {
      return req.id == resp.id;
    }, orElse: () { return null; });
    
    // If there was no matching ID then sent back an error.
    if(match == null) {
      _sendError(null, new RpcError(-32602, "Invalid params", "No matching id: " + resp.id.toString()));
    } else {
      if(resp.error == null) {
        match.responseReceivedCompleter.complete(resp);
      } else {
        match.responseReceivedCompleter.completeError(RpcError);
      }
      sentRequests.remove(match);
    }
    
  }
  
  /**
   * Sends an error as a response to the endpoint.
   */
  void _sendError(int id, RpcError error) {
    RpcResponse resp = new RpcResponse();
    resp.error = error;
    resp.id = id;
    
    String json = JSON.stringify(resp);
    _sendJson(json);
  }
  
  /**
   * Sends back data as a JSON string.
   */
  Future _sendJson(String json);
  
  /**
   * Replies to all active requests with a connection closing error and returns a Future that completes when all requests have been closed.
   * 
   * Code: -32001
   */
  Future _closeConnection();
  
  Future close() {
    List<Future> responses = [];
    for(RpcRequest req in receivedRequests) {
      responses.add(req.respondError(-32001, "Server error", "Connecting closing."));
    }
    
    return Future.wait(responses).then((_) {
      _closeConnection();
    });
  }

}
