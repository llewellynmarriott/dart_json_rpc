import '../lib/json_rpc.dart';

main() {
  
  RpcServer server = new RpcServer(new HttpProtocol());
  
  server.on('trigger.get').listen((RpcRequest req) {
    req.respondError(1337, "Woah hold up there buddy.", {});
  });
  
  server.errorReceived.listen((RpcResponse resp) {
    print('Error: ' + resp.error.toString());
  });
  
  server.listen('localhost', 8080).then((_) {
    print('Server listening for connections');
    
    RpcClient client = new RpcClient(new HttpClientProtocol());
    
    client.errorReceived.listen((RpcResponse resp) {
      print('Error: ' + resp.error.toString());
    });
    
    client.connectTo("http://localhost:8080/").then((_) {
      client.request(new RpcRequest("trigger.get", {})).then((RpcResponse resp) {
        print('Got resp!');
      });
    });
  });
  
  
   
  
}