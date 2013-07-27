part of json_rpc;

class HttpClientConnector extends ClientConnector {
  
  // HTTP client for transfering data.
  HttpClient _client;
  
  /**
   * Uses HTTP to communicate between the client and the server.
   */
  HttpClientConnector(Uri uri) : super(uri, false);
  
  Future connect() {
    Completer c = new Completer();
    
    // Create new client for requests.
    _client = new HttpClient();
    
    c.complete();
    
    return c.future;
  }
    
  Future send(RpcRequest req) {
    
    // Stringify request into json.
    var json = JSON.stringify(req);
    
    return _sendData(json).then((String data) {
      RpcResponse resp = RpcResponse.fromJson(JSON.parse(data));
      return resp;
    });
  }
  
  Future _sendData(Object data) {
    return _client.postUrl(uri).then((HttpClientRequest req) {
      // JSON-RPC content
      req.headers.contentType = new ContentType( "application", "json-rpc", charset: "utf-8" );
      // Keep the connection active to speed up future requests.
      req.headers.add( HttpHeaders.CONNECTION, "keep-alive");
      
      print('Client sent: ' + data);
      // Convert data to string and write.
      req.write(data);
      
      // Finish the request.
      return req.close();
    }).then(_readResponse);
  }
  
  Future _readResponse(HttpClientResponse resp) {
    Completer c = new Completer();
    
    // Decode response.
    var stream = resp.transform(new StringDecoder());
    
    // Buffer to store data in until it has all been retreived.
    var buffer = "";
    stream.listen((String data) {
      buffer += data;
    }, onDone: () {
      
      print('Client received: ' + buffer);
      c.complete(buffer);
      
    }, cancelOnError: true);
    
    return c.future;
    
  }
    
  
  Future close() {
    Completer c = new Completer();
    _client.close(force: true);
    
    c.complete();
    
    return c.future;
  }
}