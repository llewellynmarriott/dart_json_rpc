part of websocket_server_example;

class Car {
  String colour;
  String name;
  int value;
  
  Car(this.colour, this.name, this.value);
  
  HashMap toJson() {
    return {'colour':colour, 'name':name, 'value':value};
  }
  
  static Car fromJson(HashMap json) {
    return new Car(json['colour'], json['name'], int.parse(json['value']));
  }
}