part of json_rpc;

class RpcError {
  int code;
  String message;
  dynamic data;
  
  static RpcError fromJson(Map json) {
    var error = new RpcError();
    
    error.code = json['code'];
    error.message = json['message'];
    error.data = json['data'];
    
    return error;
  }
  
  String toString() {
    return '(' + code.toString() + ') ' + message + ' - ' + data;
  }
  
  Object toJson() {
    var json = {};
    json['code'] = code;
    json['message'] = message;
    json['data'] = data;
    
    return json;
  }
}