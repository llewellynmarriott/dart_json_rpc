part of json_rpc;

class RpcClient {

  /**
   * [RpcProtocol] to use to connect to the JSON-RPC server.
   */
  RpcProtocol protocol;
  
  RpcUser user;
  
  HashMap<String, StreamController> controllers = new HashMap<String, StreamController>();
  
  StreamController<RpcResponse> errorReceivedController = new StreamController.broadcast();
  
  /**
   * An [RpcClient] handles JSON-RPC calls to the specified [Uri] [uri].
   */
  RpcClient(this.protocol);
  
  /**
   * Connects to the JSON-RPC server.
   */
  Future connectTo(String url) {
    return protocol.connectTo(url).then((RpcUser user) {
      this.user = user;
      user.requestReceived.listen(handleRequest);
      user.errorReceived.listen(handleError);
    });
  }
  
  Stream<RpcResponse> get errorReceived => errorReceivedController.stream;
  
  /**
   * Sends an [RpcRequest] to the server and returns a [Future] that completes with an [RpcResponse].
   */
  Future request(RpcRequest req) => user.request(req);
  
  Stream on(String method) {
    // Create completer if it doesn't exist.
    if(!controllers.containsKey(method)) {
      controllers[method] = new StreamController.broadcast();
    }
    
    return controllers[method].stream;
  }
  
  void handleRequest(RpcRequest req) {
    // Create completer if it doesn't exist.
    if(controllers.containsKey(req.method)) {
      controllers[req.method].add(req);
    } else {
      print('Cannot handle');
    }
  }
  
  void handleError(RpcResponse req) {
    errorReceivedController.add(req);
  }

  /**
   * Closes the clients connection to the server.
   */
  void close() {
    user.close();
  }
  
}