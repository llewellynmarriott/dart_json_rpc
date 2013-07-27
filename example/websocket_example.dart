import '../lib/json_rpc.dart';

main() {
  
  RpcServer server = new RpcServer(new WebSocketServerConnector('localhost', 8080));
  
  server.on('trigger.get').listen((RpcRequest req) {
    req.respondError(1337, "Woah hold up there buddy.", {});
  });
  
  server.listen().then((_) {
    print('Server listening for connections');
  });
  
  RpcClient client = new RpcClient(new WebSocketClientConnector(Uri.parse("ws://localhost:8080/")));
  
  client.connect().then((_) {
    client.send(new RpcRequest("trigger.get", {}));
    client.send(new RpcRequest("trigger.get", {}));
    client.send(new RpcRequest("trigger.get", {}));
    client.send(new RpcRequest("trigger.get", {}));
    client.send(new RpcRequest("trigger.get", {}));
  });
   
  
}