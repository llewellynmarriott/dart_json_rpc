part of json_rpc;

class RpcError {
  int code;
  String message;
  dynamic data;
  
  RpcError(this.code, this.message, this.data);
  
  static RpcError fromJson(Map json) {
    var error = new RpcError(json['code'], json['message'], json['data']);
    return error;
  }
  
  String toString() {
    return '(' + code.toString() + ') ' + message + ' - ' + data.toString();
  }
  
  Object toJson() {
    var json = {};
    json['code'] = code;
    json['message'] = message;
    json['data'] = data;
    
    return json;
  }
}