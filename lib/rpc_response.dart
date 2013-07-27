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
   * Creates an [RpcResponse] object from a JSON-RPC result object.
   */
  static RpcResponse fromJson(Map json) {
    var resp = new RpcResponse();
    
    resp.result = json['result'];
    resp.id = json['id'];
    if(json['error'] != null) {
      resp.error = RpcError.fromJson(json['error']);
    }
    
    
    return resp;
  }
  
  Object toJson() {
    var json = {};
    
    json['result'] = result;
    
    if(error != null) {
      json['error'] = error.toJson();
    }
    
    json['id'] = id;
    
    return json;
  }
}