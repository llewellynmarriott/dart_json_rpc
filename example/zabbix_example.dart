import '../lib/json_rpc.dart';

main() {
  
  RpcClient client = new RpcClient(new HttpClientProtocol());
  
  client.errorReceived.listen((RpcResponse resp) {
    print('Error: ' + resp.error.toString());
  });
  
  client.connectTo("http://10.70.8.20/zabbix/api_jsonrpc.php").then((_) {
    client.request(new RpcRequest("trigger.get", {})).then((RpcResponse resp) {
      print('Got resp!');
    });
  });
  

  
  
   
  
}