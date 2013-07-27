part of json_rpc;

class ClientConnector {
  
  /**
   * Does this connector support both sending and recieving of data.
   */
  bool multiWay;
  /**
   * URI of the server to connect to.
   */
  Uri uri;
  
  StreamController _requestReceivedController = new StreamController.broadcast();
  
  ClientConnector(this.uri, this.multiWay);
  
  Future connect() {}
  
  Future send(RpcRequest req) {}
  
  Stream get requestReceived => _requestReceivedController.stream;
  
  Future close() {}
  
}