part of json_rpc;

class RpcRequest {
  
  /**
   * Method to call.
   */
  String method;
  /**
   * Parameters of the request.
   */
  var params;
  /**
   * ID that will be returned with the response.
   */
  var id;
  
  /**
   * Additional parameters to add to the request, used for creating new request types.
   */
  Map base = {};
  
  /**
   * Version of the supported JSON-RPC protocol.
   */
  String jsonrpc = "2.0";
  
  /**
   * If the request is being received then this is set to the user the request is from, otherwise it is undefined.
   * 
   * For one way connectors this is not persistent.
   */
  RpcUser user;
  
  /**
   * Creates a new [RpcRequest] to send to the RPC server.
   */
  RpcRequest(this.method, this.params);
  
  /**
   * Writes a response back to the user who sent this request with a matching ID.
   */
  Future respond(var data) {
    var resp = new RpcResponse();
    resp.id = id;
    resp.request = this;
    resp.result = data;
    
    return user.respond(resp);
  }
  
  Future respondError(int code, String message, var data) {
    var resp = new RpcResponse();
    resp.id = id;
    resp.request = this;
    
    var error = new RpcError();
    error.code = code;
    error.message = message;
    error.data = data;
    
    resp.error = error;
    
    return user.respond(resp);
  }
  
  /**
   * Converts the request to a JSON object to send to the RPC server.
   */
  Object toJson() {
    var json = base;
    
    json['jsonrpc'] = jsonrpc;
    json['method'] = method;
    json['params'] = params;
    json['id'] = id;
    
    return json;
  }
  
  static RpcRequest fromJson(Map json) {
    var req = new RpcRequest(json['method'], json['params']);
    
    req.jsonrpc = json['jsonrpc'];
    req.method = json['method'];
    req.params = json['params'];
    req.id = json['id'];
    
    return req;
  }
  
}