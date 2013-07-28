part of json_rpc;

abstract class RpcProtocol {
  
  /**
   * Does this connector support both sending and recieving of data.
   */
  RpcServer server;
  
  StreamController _userConnectedController = new StreamController.broadcast();
 
  RpcProtocol();
  
  Future listen(dynamic address, int port);
  Future close();
  Future connectTo(String url);
  
  Stream get userConnected => _userConnectedController.stream;
  
}