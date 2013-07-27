part of json_rpc;

class RpcClient {

  /**
   * [ClientConnector] to use to connect to the JSON-RPC server, default is HTTP.
   */
  ClientConnector connector;
  
  HashMap<String, StreamController> _controllers = new HashMap<String, StreamController>();
    
  String _auth;
  int _activeQueries = 0;
  int _currentId = 0;
  
  /**
   * An [RpcClient] handles JSON-RPC calls to the specified [Uri] [uri].
   */
  RpcClient(this.connector) {
    connector.requestReceived.listen(_handleRequest);
  }
  
  /**
   * Returns the amount of currently active queries [int] to the JSON-RPC server.
   */
  int activeQueries() {
    return _activeQueries;
  }
  
  /**
   * Connects to the JSON-RPC server.
   */
  Future connect() {
    return connector.connect();
  }
  
  /**
   * Sends an [RpcRequest] to the server and returns a [Future] that completes with an [RpcResponse].
   */
  Future send(RpcRequest req) {
        
    // Used so we get a unique response.
    req.id = _currentId;
    _currentId++;

    // Increase the amount of active queries.
    _activeQueries++;
    
    // Send request to the server.
    return connector.send(req);
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
    if(_controllers.containsKey(req.method)) {
      _controllers[req.method].add(req);
    } else {
      print('Cannot handle');
    }
  }

  /**
   * Closes the clients connection to the server.
   */
  void close() {
    connector.close();
  }
  
}