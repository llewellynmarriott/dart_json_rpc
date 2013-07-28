part of json_rpc;

class RpcClient {

  /**
   * [RpcProtocol] to use to connect to the JSON-RPC server.
   */
  RpcProtocol protocol;
  
  RpcUser user;
  
  HashMap<String, StreamController> _controllers = new HashMap<String, StreamController>();
  
  StreamController<RpcResponse> _errorReceivedController = new StreamController.broadcast();
  
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
      user.requestReceived.listen(_handleRequest);
      user.errorReceived.listen(_handleError);
    });
  }
  
  Stream<RpcResponse> get errorReceived => _errorReceivedController.stream;
  
  /**
   * Sends an [RpcRequest] to the server and returns a [Future] that completes with an [RpcResponse].
   */
  Future request(RpcRequest req) => user.request(req);
  
  Stream on(String method) {
    // Create completer if it doesn't exist.
    if(!_controllers.containsKey(method)) {
      _controllers[method] = new StreamController.broadcast();
    }
    
    return _controllers[method].stream;
  }
  
  void _handleRequest(RpcRequest req) {
    // Create completer if it doesn't exist.
    if(_controllers.containsKey(req.method)) {
      _controllers[req.method].add(req);
    } else {
      print('Cannot handle');
    }
  }
  
  void _handleError(RpcResponse req) {
    _errorReceivedController.add(req);
  }

  /**
   * Closes the clients connection to the server.
   */
  void close() {
    user.close();
  }
  
}