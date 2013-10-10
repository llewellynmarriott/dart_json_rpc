part of json_rpc;

class HttpClientUser extends RpcUser {
  
  Uri uri;
  HttpClient client = new HttpClient();
  
  HttpClientUser(this.uri);

  void readRequest() {}
  
  Future close(String reason) {
    client.close(force: true);
    return super.close(reason);
  }
  
  Future readResponse(HttpClientResponse resp) {
    Completer c = new Completer();
    
    // Decode response.
    var stream = resp.transform(new Utf8Decoder());
    
    // Buffer to store data in until it has all been retreived.
    var buffer = "";
    stream.listen((String data) {
      buffer += data;
    }, onDone: () {
      receiveData(buffer);
    }, cancelOnError: false);
    
    c.complete();
    return c.future;
  }
  
  Future sendData(String json) {
    //client.findProxy = (Uri uri) { return "PROXY 127.0.0.1:8888"; };
    return client.postUrl(uri).then((HttpClientRequest req) {
      // JSON-RPC headers.
      req.headers.contentType = new ContentType( "application", "json-rpc", charset: "utf-8" );
      req.headers.add( HttpHeaders.CONNECTION, "keep-alive");
      req.headers.contentLength = json.length;
      req.write(json);
      // Finish the request.
      return req.close();
    }).then(readResponse);
  }
} 