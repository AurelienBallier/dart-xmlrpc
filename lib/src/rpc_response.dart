part of xmlrpc;

/**
 * Represents an un/successful response.
 * See [RpcRequest] for the detailed description of parameter's types.
 */
class RpcResponse extends _ParamsIterationSupport {
  /**
	 * The main state of the request.
	 */
  bool isSuccess;

  @override
  Iterator<Object> get iterator => new _ParamsIterator(this);

  var builder;
  var _root;
  List _params = [];

  /**
	 * Creates new response from scratch.
	 * Use [successful] flag for the initial state of the request.
	 */
  RpcResponse({this.isSuccess: true}) {
    _makeRoot();
    _root = builder.build();
  }

  /**
	 * Parses an external response from text.
	 */
  RpcResponse.fromText(String body) {
    _root = parse(body);
    var resultNode = _getResultNode();

    isSuccess = (resultNode.name.toString() != FAULT_NODE);

    if (isSuccess) {
      resultNode.findAllElements('param').forEach((XmlNode paramNode) => _params.add(RpcParam.fromParamNode(paramNode)));
    } else {
      XmlElement valueNode = resultNode.children.singleWhere((XmlNode n) => (n.nodeType.toString() == 'XmlNodeType.ELEMENT'));
      XmlElement typeNode = valueNode.children.singleWhere((XmlNode n) => (n.nodeType.toString() == 'XmlNodeType.ELEMENT'));

      _params.add(RpcParam.fromXmlElement(typeNode));
    }
  }

  @override
  String toString() {
    _makeRoot();
    _root = builder.build();

    return _root.toString();
  }

  void _makeRoot() {
    builder = new XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element(RESPONSE_NODE, nest: () {
      builder.element((isSuccess ? PARAMS_NODE : FAULT_NODE), nest: () {
        _makeParams();
      });
    });
  }

  void _constructFaultMap(Map fault, Object p){
    if(p.runtimeType.toString() == "int"){
      fault["faultCode"] = p;
    }else if(p.runtimeType.toString() == "String"){
      fault["faultString"] = p;
    }    
  }
  
  void _makeParams() {
    if (!isSuccess) {
      assert(_params.length < 2);
    }

    if (isSuccess) {
      _params.forEach((Object param) {
        builder.element('param', nest: () {
          RpcParam.buildParam(builder, param);
        });
      });
    } else {
      _params.forEach((Object param) {
        RpcParam.buildParam(builder, param);
      });
    }
  }

  XmlElement _getResultNode() {
    var e = _root.rootElement.findElements('params');
    if (e.length > 0) {
      return e.first;
    }

    return _root.rootElement.findElements('fault').single;
  }
}
