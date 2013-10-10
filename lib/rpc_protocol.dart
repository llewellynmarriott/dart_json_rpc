part of json_rpc;

abstract class RpcProtocol {
  
  RpcServer server;
  StreamController userConnectedController = new StreamController.broadcast();
  RpcProtocol();
  
  Future listen(dynamic address, int port);
  Future close();
  Future connectTo(Uri uri);
  
  Stream get userConnected => userConnectedController.stream;
  
}