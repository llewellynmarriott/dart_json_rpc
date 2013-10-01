part of websocket_server_example;

class CarMethodHandler extends RpcMethodHandler {
  void doMain(RpcRequest req) {
    req.respond(true);
  }
  
  void doGet(RpcRequest req) {
    req.respond(Program.cars);
  }
  
  @RpcParamType(Car)
  void doAdd(RpcRequest req, Car c) {
    Program.cars.add(c);
    req.respond(true);
  }
  
  @RpcParamType(Car)
  void doRemove(RpcRequest req, Car car) {
    Program.cars.removeWhere((Car c) {
      return c.name == car.name;
    });
    req.respond(true);
  }
}