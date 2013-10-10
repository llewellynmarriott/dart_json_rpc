import '../lib/json_rpc.dart';

main() {
  
  RpcProtocol clientProtocol = new HttpClientProtocol();

  RpcClient.connectTo(Uri.parse("http://10.70.8.20/zabbix/api_jsonrpc.php"), clientProtocol).then((RpcUser user) {
    user.request("trigger.get", {}).then((RpcResponse resp) {
      print(resp.result);
    });
    
    user.errorReceived.listen((RpcResponse resp) {
      print('Error: ' + resp.error.toString());
    });
  });
}