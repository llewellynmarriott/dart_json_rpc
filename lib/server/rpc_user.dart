part of json_rpc;

class RpcUser {

  ServerConnector connector;
  StreamController _requestReceivedController = new StreamController.broadcast();
  
  RpcUser(this.connector);
  
  
  /*
   * Returns a [Stream] that will send back data as an [RpcRequest] when a request is received from the client.
   */
  Stream<RpcRequest> get requestReceived => _requestReceivedController.stream;
  
  
  
  /* 
   * Sends an [RpcRequest] request to the client if the [ServerConnector] connector supports multi-way communication.
   */
  void send(RpcRequest req) {
    
  }
  
  /* 
   * Sends an [RpcResponse] response back to the client, returns a Future that completes when the response has been sent.
   */
  Future respond(RpcResponse resp) {
    
  }
  
  Future close() {}

}
