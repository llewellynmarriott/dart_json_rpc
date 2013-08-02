import 'package:dart_json_rpc/json_rpc_html.dart';

main() {
  
    RpcClient client = new RpcClient(new HtmlWSClientProtocol());
    
    client.errorReceived.listen((RpcResponse resp) {
      print('Error: ' + resp.error.toString());
    });
    
    client.connectTo("ws://localhost:8080/").then((_) {
      print('Connected');
      client.request(new RpcRequest("trigger.get", {})).then((RpcResponse resp) {
        print('Got resp!');
      });
    });
  
  
   
  
}