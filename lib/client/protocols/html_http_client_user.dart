part of json_rpc;

class HtmlHttpClientUser extends RpcUser {
  
  Uri uri;
  String username;
  String password;
  
  HttpRequest httpRequest = new HttpRequest();
  
  HtmlHttpClientUser(this.uri);

  void readRequest() {}
  
  Future close(String reason) {
    return super.close(reason);
  }
  
  Future readyStateChange(ProgressEvent e) {
    if (httpRequest.readyState == HttpRequest.DONE &&
        (httpRequest.status == 200 || httpRequest.status == 0)) {
      receiveData(httpRequest.responseText);
    }
  }
  
  Future sendData(String data) {
    httpRequest.onReadyStateChange.listen(readyStateChange);
    httpRequest.open("POST", uri.toString(), async: false, user: username, password: password);
  }
} 