part of json_rpc;

class HttpUser extends RpcUser {
  
  HttpRequest httpRequest;
  
  HttpUser(this.httpRequest) {
    _readRequest();
  }
  
  Future connect(Uri uri) {}
  
  /**
   * Reads data from the [HttpRequest] and transforms it into a [RpcRequest] object then calls the event indicating there is a new request.
   */
  _readRequest() {
    String buffer = "";
    httpRequest.transform(new StringDecoder()).listen((String data) {
      buffer+=data;
    }, onDone: () {
      _receiveJson(buffer);      
    }, onError: (e) {
      print(e);
    }, cancelOnError: true);
  }
  
  Future _closeConnection() {
    Completer c = new Completer();
    httpRequest.response.close();
    c.complete();
    return c.future;
  }
  
  Future _sendJson(Object json) {
    Completer c = new Completer();
    httpRequest.response.write(json);
    httpRequest.response.close();
    c.complete();
    return c.future;
    //return httpRequest.response.close();
  }
} 