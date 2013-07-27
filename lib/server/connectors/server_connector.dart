part of json_rpc;

class ServerConnector {
  
  /**
   * Does this connector support both sending and recieving of data.
   */
  bool multiWay;
  int port;
  var address;
  RpcServer server;
  
  StreamController _userConnectedController = new StreamController.broadcast();
 
  ServerConnector(this.address, this.port, this.multiWay);
  Future listen() {}
  Future send(Object data) {}
  Future close() {}
  
  Stream get userConnected => _userConnectedController.stream;
  
}