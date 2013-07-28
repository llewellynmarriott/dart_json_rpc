part of json_rpc;


class RpcResponse {
  /**
   * The [RpcRequest] request that this is a response to.
   */
  RpcRequest request;
  /**
   * The result of the request.
   */
  dynamic result;
  /**
   * [dynamic] ID of the resonse which matches the ID of the request.
   */
  dynamic id;
  /**
   * Undefined if no errors occured.
   */
  RpcError error;
  /**
   * Version of the supported JSON-RPC protocol.
   */
  String jsonrpc = "2.0";
  
  /**
   * Creates an [RpcResponse] object from a JSON-RPC result object.
   */
  static RpcResponse fromJson(Map json) {
    var resp = new RpcResponse();
    
    resp.result = json['result'];
    resp.id = json['id'];
    resp.jsonrpc = json['jsonrpc'];
    if(json['error'] != null) {
      resp.error = RpcError.fromJson(json['error']);
    }
    
    
    return resp;
  }
  
  Object toJson() {
    var json = {};
    
    if(result != null) {
      json['result'] = result;
    }
    
    if(error != null) {
      json['error'] = error.toJson();
    }
    
    json['id'] = id;
    json['jsonrpc'] = jsonrpc;
    
    return json;
  }
}