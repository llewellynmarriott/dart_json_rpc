part of json_rpc;

class RpcServer extends RpcRequestHandler {
  
  RpcProtocol protocol;
  
  List<RpcUser> users = [];
  
  RpcServer(this.protocol) {
    protocol.server = this;
    protocol.userConnected.listen(addUser);
  } 
  
  /**
   * Starts listening and accepting connections.
   **/
  Future listen(dynamic address, int port) {
    return protocol.listen(address, port);
  }
  
  /**
   * Adds a currently connected user to the list of users and begins listening for requests.
   */
  void addUser(RpcUser user) {
    users.add(user);
    
    user.requestReceived.listen(handleRequest);
    user.errorReceived.listen(handleError);
    user.connectionClosed.listen((_) {
      print('User disconnected');
      users.remove(user);
    });
  }
  
  /**
   * Closes connection to a user.
   */
  void removeUser(RpcUser user) {
    user.close("User removed");
    users.remove(user);
  }
  
  /**
   * Stops listening for new connections and closes all current connections.
   */
  Future close() {
    List<Future> futures = [];
    // Close request on each user
    users.forEach((RpcUser user) {
      futures.add(user.close("Closing server"));
    });
    
    return Future.wait(futures).then((_) {
      protocol.close();
    });
  }
  
}