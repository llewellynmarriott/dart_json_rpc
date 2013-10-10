import '../lib/json_rpc.dart';

main() {
  
  RpcProtocol serverProtocol = new HttpProtocol();
  RpcProtocol clientProtocol = new HttpClientProtocol();
  
  RpcServer server = new RpcServer(serverProtocol);
  
  server.on("helloworld").listen((RpcRequest req) {
    req.respond("Ahoy!");
  });
  
  server.listen('localhost', 8080).then((_) {
    RpcClient.connectTo(Uri.parse("http://localhost:8080/"), clientProtocol).then((RpcUser user) {
      user.request("helloworld", {}).then((RpcResponse resp) {
        print(resp.result);
      });
      
      user.errorReceived.listen((RpcResponse resp) {
        print('Error: ' + resp.error.toString());
      });
    });
  });
}