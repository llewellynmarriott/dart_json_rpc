library websocket_server_example;

import 'package:dart_json_rpc/json_rpc.dart';
import 'dart:async';
import 'dart:collection';


part 'car.dart';
part 'method_handlers/car_method_handler.dart';

void main() {
  Program.main();
}

class Program {
  static List<Car> cars = new List<Car>();
  static RpcServer server;
  
  static void main() {
    server = new RpcServer(new WebSocketProtocol());
    
    server.registerMethodHandler('car', CarMethodHandler);
    
    server.errorReceived.listen((RpcResponse resp) {
      print('Error: ' + resp.error.toString());
    });
    
    server.listen('localhost', 8080).then((_) {
      Client client = new Client();
      client.connect().then((_) {
        
        client.listCars().then((_) {
          Car newCar = new Car('My purple car', 'purple', 999);
          client.addCar(newCar).then((_) {
            client.listCars().then((_) {
              client.removeCar(newCar).then((_) {
                client.listCars();
              });
            });
          });
        });
        
      });
    });
  }
}


class Client {
  RpcClient client = new RpcClient(new WebSocketProtocol());
  
  void main() {
    client.errorReceived.listen((RpcResponse resp) {
      print('Error: ' + resp.error.toString());
    });
  }
  
  Future connect() {
    return client.connectTo("ws://localhost:8080/");
  }
  
  Future addCar(Car c) {
    return req('car.add', c);
  }
  
  Future listCars() {
    return req('car.get').then((RpcResponse resp) {
      print(resp.result);
    });
  }
  
  Future removeCar(Car c) {
    return req('car.remove', c);
  }
  
  Future req(String method, [dynamic params]) {
    return client.request(new RpcRequest(method, params));
  }
}