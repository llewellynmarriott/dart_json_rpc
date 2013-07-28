part of json_rpc;

class RpcServer {
  
  RpcProtocol protocol;
  HashMap<String, StreamController> _controllers = new HashMap<String, StreamController>();
  StreamController<RpcResponse> _errorReceivedController = new StreamController.broadcast();
  List<RpcUser> _users = [];
  
  RpcServer(this.protocol) {
    protocol.server = this;
    protocol.userConnected.listen(_addUser);
  }
  
  /**
   * Returns a [Stream] that will send back data as an [RpcResponse] when a response with no ID is received from the server.
   */
  Stream<RpcResponse> get errorReceived => _errorReceivedController.stream;
  
  Stream on(String method) {
    // Create completer if it doesn't exist.
    if(!_controllers.containsKey(method)) {
      _controllers[method] = new StreamController.broadcast();
    }
    
    return _controllers[method].stream;
  }
  
  void _handleRequest(RpcRequest req) {
    // Create completer if it doesn't exist.
    if(!_controllers.containsKey(req.method)) {
      _controllers[req.method] = new StreamController.broadcast();
    }
    
    _controllers[req.method].add(req);
  }
  
  void _handleError(RpcResponse req) {
    _errorReceivedController.add(req);
  }
  
  /*
   * Starts listening and accepting connections.
   */
  Future listen(dynamic address, int port) {
    return protocol.listen(address, port);
  }
  
  /*
   * Adds a currently connected user to the list of users and begins listening for requests.
   */
  void _addUser(RpcUser user) {
    _users.add(user);
    
    user.requestReceived.listen(_handleRequest);
    user.errorReceived.listen(_handleError);
  }
  
  /*
   * Closes connection to a user.
   */
  void removeUser(RpcUser user) {
    user.close();
    _users.remove(user);
  }
  
  /*
   * Returns a list of currently connected users.
   */
  List<RpcUser> get users => _users.toList(growable: false);
  
  /*
   * Stops listening for new connections and closes all current connections.
   */
  Future close() {
    List<Future> futures = [];
    // Close request on each user
    _users.forEach((RpcUser user) {
      futures.add(user.close());
    });
    
    return Future.wait(futures).then((_) {
      protocol.close();
    });
    
    
  }
  
}