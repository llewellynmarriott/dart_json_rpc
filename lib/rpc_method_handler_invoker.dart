part of json_rpc;

abstract class RpcMethodHandlerInvoker {
  Map<String, Type> methodHandlers = new Map<String, Type>();
  
  void registerMethodHandler(String handlerName, Type handlerType) {
    methodHandlers[handlerName] = handlerType;
  }
  
  bool _checkMethodHandlers(RpcRequest req) {
    String method = req.method;
    // If the method name contains a dot then get everything before the dot.
    String subMethod = '';
    if(method.contains(".")) {
      List<String> split = method.split(".");
      method = split[0];
      subMethod = split[1];
    }
    
    if(methodHandlers.containsKey(method)) {
      return _runMethod(req, methodHandlers[method], method, subMethod);
    }
    
    return false;
  }
  
  bool _runMethod(RpcRequest req, Type classType, String className, String methodName) {
    ClassMirror classMirror = reflectClass(classType);
       
    InstanceMirror instanceMirror = classMirror.newInstance(new Symbol(''), []);
    
    RpcMethodHandler rpcMethod = instanceMirror.reflectee;

    if(methodName.length > 0) {
      methodName = 'do' + _capitalize(methodName);
    } else {
      methodName = 'doMain';
    }

    // Check if method exists.
    if(classMirror.methods.containsKey(new Symbol(methodName))) {
      MethodMirror methodMirror = classMirror.methods[new Symbol(methodName)];
      // Check if the method has an optional param.
      Object optionalParam;
      if(methodMirror.parameters.length > 1) {
        Type paramType = _getOptionalParamType(methodMirror);

        optionalParam = _getOptionalParam(paramType, req.params);
      }
      
      if(optionalParam == null) {
        instanceMirror.invoke(new Symbol(methodName), [req]);
      } else {
        instanceMirror.invoke(new Symbol(methodName), [req, optionalParam]);
      }
      return true;
    }
    
    
    return false;
    
  }
  
  Object _getOptionalParam(Type paramType, dynamic params) {
    ClassMirror classMirror = reflectClass(paramType);
    
    InstanceMirror instanceMirror = classMirror.invoke(new Symbol('fromJson'), [params]);
    
    return instanceMirror.reflectee;
  }
  
  Type _getOptionalParamType(MethodMirror methodMirror) {
    ParameterMirror paramMirror = methodMirror.parameters[1];
    return paramMirror.
  }
  
  String _capitalize(String str) {
    str = str.toLowerCase();
    
    String first = str.substring(0, 1);
    String rest = str.substring(1, str.length);
    
    return first.toUpperCase() + rest;
  }
}