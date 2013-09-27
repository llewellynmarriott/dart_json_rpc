import '../lib/json_rpc.dart';

main() {
  
  RpcClient client = new RpcClient(new HttpClientProtocol());
  
  RpcServer server = new RpcServer(new HttpProtocol());
  
  server.on("trigger.get").listen((RpcRequest req) {
    req.respond("Hiiiiii");
  });
  
  server.listen('localhost', 8080).then((_) {
    client.connectTo("http://localhost:8080/").then((_) {
      client.request(new RpcRequest("trigger.get", {})).then((RpcResponse resp) {
        print('Got resp!');
      });
    });
  });
  
  client.errorReceived.listen((RpcResponse resp) {
    print('Error: ' + resp.error.toString());
  });
  
  
  
  
   
  
}