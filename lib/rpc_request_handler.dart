part of json_rpc;

class RpcRequestHandler extends RpcMethodHandlerInvoker {
  HashMap<String, StreamController> controllers = new HashMap<String, StreamController>();
  StreamController<RpcResponse> errorReceivedController = new StreamController.broadcast();
  /**
   * Returns a [Stream] that will send back data as an [RpcResponse] when a response with no ID is received from the server.
   */
  Stream<RpcResponse> get errorReceived => errorReceivedController.stream;
  
  Stream on(String method) {
    // Checks if a stream controller exists, if not creates one.
    if(!controllers.containsKey(method)) {
      controllers[method] = new StreamController.broadcast();
    }
    
    return controllers[method].stream;
  }
  
  void handleRequest(RpcRequest req) {
    bool ranMethodHandler = _checkMethodHandlers(req);
    
    if(controllers.containsKey(req.method)) {
      controllers[req.method].add(req);
    } else {
      if(!ranMethodHandler) {
        req.respondError(new RpcError(-32600, "Invalid request", "No method found"));
      }
    }
    
  }
  
  void handleError(RpcResponse req) {
    errorReceivedController.add(req);
  }
}