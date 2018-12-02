part of xmlrpc;

/**
 * Represents all the data that is/should be passed.
 * The parameter list can be filled with any legal _Dart_ value.
 *
 * The conversion table is bidirectional:
 *
 * `string`, `int`, `bool`, `double` <-> `<type>value</type>`
 *
 * `new DateTime()` <-> `<dateTime.iso8601>19980717T14:08:55</dateTime.iso8601>`
 *
 * `null` <-> `<nil />`
 *
 * `new List()` <-> `<array><data><value>typeValue</value></data></array>`
 *
 * `Map<KeyType, ValueType>` <-> `<struct><member><name>keyType.toString()</name><value><string>valueType</string></value></member></struct>`
 *
 * `new List<int>()` <-> `<base64>somedata</base64>`
 */
class RpcRequest extends _ParamsIterationSupport {
	List _params = [];

  var builder;
	xml.XmlDocument _root;

  String _method;

	/**
	* The method name.
	*
	*     <methodCall>
	*         <methodName>...</methodName>
	*     </methodCall>
	*/
	String get method =>
		_method;

	void set method(String method) {
    _method = method;
  }

	@override
	Iterator<Object> get iterator =>
		new _ParamsIterator(this);

	/**
	* Constructs an empty request.
	*/
	RpcRequest({String method, List params}) {
		if (method != null)
			this.method = method;

		if (params != null)
			this._params = params;
	}

	/**
	 * Constructs a request from the given text.
	 * The XML header `<?xml?>` is optional and ignored.
	 */
	RpcRequest.fromText(String body) {
		_root = xml.parse(body);
    var resultNode = _getResultNode();

    _method = _getMethodNode().text;

    resultNode.findAllElements('param').forEach((xml.XmlNode paramNode){
      _params.add(RpcParam.fromParamNode(paramNode));
    });
	}

	/**
	* Returns a string representation for the request.
	*/
	@override
	String toString() {
    build();
    _root = builder.build();
    return _root.toString();
	}

  /**
  * Build the request.
  */
  void build(){
    builder = new xml.XmlBuilder();
    builder.processing('xml', "version='1.0'");
    builder.element(METHOD_CALL_NODE, nest: () {
      builder.element(METHOD_NAME_NODE, nest: _method);
      builder.element(PARAMS_NODE, nest: buildParam);
    });
  }

  /**
  * Add params to the request builder.
  */
  void buildParam(){
    _params.forEach((param) {
      builder.element(PARAM_NODE, nest: (){
        RpcParam.buildParam(builder, param);
      });
    });
  }

  xml.XmlElement _getResultNode() =>
      _root.rootElement.findElements('params').first;

  xml.XmlElement _getMethodNode() =>
      _root.rootElement.findElements('methodName').first;
}
