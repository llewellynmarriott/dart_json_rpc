import 'package:dart_json_rpc/json_rpc.dart';

main() {
  
 RpcServer server = new RpcServer(new WebSocketProtocol());
 
 
  server.on('trigger.get').listen((RpcRequest req) {
    //req.respondError(1337, "Woah hold up there buddy.", {});
    req.respond('Hey buddy, got your message!');
  });
  
  server.errorReceived.listen((RpcResponse resp) {
    print('Error: ' + resp.error.toString());
  });
  
  server.listen('localhost', 8080).then((_) {
    print('Server listening for connections');
    
    RpcClient client = new RpcClient(new WebSocketProtocol());
    
    client.errorReceived.listen((RpcResponse resp) {
      print('Error: ' + resp.error.toString());
    });
    
    client.connectTo("ws://localhost:8080/").then((_) {
      print('Connected');
      client.request(new RpcRequest("trigger.get", {})).then((RpcResponse resp) {
        print('Got resp!');
      });
    });
  });
  
  
   
  
}