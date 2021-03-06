part of json_rpc;

class HttpUser extends RpcUser {
  
  HttpRequest httpRequest;
  
  HttpUser(this.httpRequest) {
    readRequest();
  }
  
  Future connect(Uri uri) {}
  
  /**
   * Reads data from the [HttpRequest] and transforms it into a [RpcRequest] object then calls the event indicating there is a new request.
   */
  readRequest() {
    String buffer = "";
    httpRequest.transform(new AsciiDecoder()).listen((String data) {
      buffer+=data;
    }, onDone: () {
      receiveData(buffer);      
    }, onError: (e) {
      print(e);
    }, cancelOnError: true);
  }
  
  Future close(String reason) {
    httpRequest.response.close();
    return super.close(reason);
  }
  
  Future sendData(String data) {
    Completer c = new Completer();
    httpRequest.response.write(data);
    httpRequest.response.close();
    c.complete();
    return c.future;
  }
} 