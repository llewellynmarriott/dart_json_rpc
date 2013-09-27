part of websocket_server_example;

class CarMethodHandler extends RpcMethodHandler {
  void doMain(RpcRequest req) {
    req.respond(true);
  }
  
  void doGet(RpcRequest req) {
    req.respond(true);
  }
  
  void doAdd(RpcRequest req, Car c) {
    Program.cars.add(c);
  }
  
  void doRemove(RpcRequest req, Car car) {
    Program.cars.removeWhere((Car c) {
      return c.name = car.name;
    });
  }
}