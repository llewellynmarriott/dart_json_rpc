part of json_rpc;

class RpcServer {
  
  ServerConnector connector;
  HashMap<String, StreamController> _controllers = new HashMap<String, StreamController>();
  List<RpcUser> _users = [];
  
  RpcServer(this.connector) {
    connector.server = this;
    connector.userConnected.listen(_addUser);
  }
  
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
  
  /*
   * Starts listening and accepting connections.
   */
  Future listen() {
    return connector.listen();
  }
  
  /*
   * Adds a currently connected user to the list of users and begins listening for requests.
   */
  void _addUser(RpcUser user) {
    _users.add(user);
    
    user.requestReceived.listen(_handleRequest);
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
    // Close request on each user
    _users.forEach((HttpServerConnectorUser user) {
      user.close();
    });
    
    connector.close();
  }
  
}