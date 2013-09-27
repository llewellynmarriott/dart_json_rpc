part of json_rpc;

class HttpClientUser extends RpcUser {
  
  String url;
  HttpClient client = new HttpClient();
  
  HttpClientUser(this.url);

  /**
   * Reads data from the [HttpRequest] and transforms it into a [RpcRequest] object then calls the event indicating there is a new request.
   */
  void readRequest() {}
  
  Future close(String reason) {
    client.close(force: true);
    return super.close(reason);
  }
  
  Future readResponse(HttpClientResponse resp) {
    Completer c = new Completer();
    
    // Decode response.
    var stream = resp.transform(new AsciiDecoder());
    
    // Buffer to store data in until it has all been retreived.
    var buffer = "";
    stream.listen((String data) {
      buffer += data;
      print(data);
    }, onDone: () {
      receiveJson(buffer);
    }, cancelOnError: true);
    
    c.complete();
    return c.future;
  }
  
  Future sendJson(String json) {
    print(json);
    return client.postUrl(Uri.parse(url)).then((HttpClientRequest req) {
      // JSON-RPC headers.
      req.headers.contentType = new ContentType( "application", "json-rpc", charset: "utf-8" );
      req.headers.add( HttpHeaders.CONNECTION, "keep-alive");
      req.write(json);
      // Finish the request.
      return req.close();
    }).then(readResponse);
  }
} 