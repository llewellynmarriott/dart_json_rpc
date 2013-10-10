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
  RpcUser user;
  
  
  Future connect() {
    
    RpcClient.connectTo(Uri.parse("ws://localhost:8080/"), new WebSocketProtocol()).then((RpcUser user) {
      this.user = user;
      user.errorReceived.listen((RpcResponse resp) {
        print('Error: ' + resp.error.toString());
      });
    });
  }
  
  Future addCar(Car c) {
    return user.request('car.add', c);
  }
  
  Future listCars() {
    return user.request('car.get', {}).then((RpcResponse resp) {
      print(resp.result);
    });
  }
  
  Future removeCar(Car c) {
    return user.request('car.remove', c);
  }
}