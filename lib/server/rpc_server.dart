part of json_rpc;

class RpcServer {
  
  RpcProtocol protocol;
  HashMap<String, StreamController> controllers = new HashMap<String, StreamController>();
  StreamController<RpcResponse> errorReceivedController = new StreamController.broadcast();
  List<RpcUser> users = [];
  
  RpcServer(this.protocol) {
    protocol.server = this;
    protocol.userConnected.listen(addUser);
  }
  
  /**
   * Returns a [Stream] that will send back data as an [RpcResponse] when a response with no ID is received from the server.
   */
  Stream<RpcResponse> get errorReceived => errorReceivedController.stream;
  
  Stream on(String method) {
    // Create completer if it doesn't exist.
    if(!controllers.containsKey(method)) {
      controllers[method] = new StreamController.broadcast();
    }
    
    return controllers[method].stream;
  }
  
  void handleRequest(RpcRequest req) {
    // Create completer if it doesn't exist.
    if(!controllers.containsKey(req.method)) {
      controllers[req.method] = new StreamController.broadcast();
    }
    
    controllers[req.method].add(req);
  }
  
  void handleError(RpcResponse req) {
    errorReceivedController.add(req);
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
  void addUser(RpcUser user) {
    users.add(user);
    
    user.requestReceived.listen(handleRequest);
    user.errorReceived.listen(handleError);
    user.connectionClosed.listen((_) {
      print('User disconnected');
      users.remove(user);
    });
  }
  
  /*
   * Closes connection to a user.
   */
  void removeUser(RpcUser user) {
    user.close();
    users.remove(user);
  }
  
  /*
   * Stops listening for new connections and closes all current connections.
   */
  Future close() {
    List<Future> futures = [];
    // Close request on each user
    users.forEach((RpcUser user) {
      futures.add(user.close());
    });
    
    return Future.wait(futures).then((_) {
      protocol.close();
    });
    
    
  }
  
}