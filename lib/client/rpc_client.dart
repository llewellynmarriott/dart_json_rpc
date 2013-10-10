part of json_rpc;

abstract class RpcClient  {
 
  /**
   * Connects to the JSON-RPC server with the specified protocol.
   */
  static Future<RpcUser> connectTo(Uri uri, RpcProtocol protocol) {
    return protocol.connectTo(uri);
  }
  
}