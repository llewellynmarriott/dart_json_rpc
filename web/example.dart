import 'package:dart_json_rpc/json_rpc_html.dart';

main() {
  RpcClient.connectTo(Uri.parse("ws://localhost:8080/"), new HtmlWSClientProtocol()).then((RpcUser user) {
    user.request("helloworld", {}).then((RpcResponse resp) {
      print(resp.result);
    });
    
    user.errorReceived.listen((RpcResponse resp) {
      print('Error: ' + resp.error.toString());
    });
  });    
}