part of json_rpc;

class HttpServerConnectorUser extends RpcUser {
  
  HttpRequest request;
  
  HttpServerConnectorUser(ServerConnector connector, this.request) : super(connector) {
    _readRequest();
  }
  
  /*
   * Reads data from the [HttpRequest] and transforms it into a [RpcRequest] object then calls the event indicating there is a new request.
   */
  _readRequest() {
    String buffer = "";
    
    request.transform(new StringDecoder()).listen((String data) {
      buffer+=data;
    }, onDone: () {
      print('Server received: ' + buffer);
      // Create request from data.
      RpcRequest req = RpcRequest.fromJson(JSON.parse(buffer));
      
      // Send RPC request back to connector.
      req.user = this;

      // Send request back as data.
      _requestReceivedController.add(req);
      
    }, cancelOnError: true);
  }
  
  Future respond(RpcResponse resp) {
    // Convert response to JSON and then write to client.
    String json = JSON.stringify(resp);
    request.response.write(json);
    print('Server sent back: ' + json);
    
    // Remove from server as this is a one way connection.
    connector.server.removeUser(this);
  }
  
  Future close() {
    return request.response.close();
  }
} 