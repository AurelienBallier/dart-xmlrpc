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
	Iterator<Object> get iterator =>
		new _ParamsIterator(this);

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

		isSuccess = resultNode.name != FAULT_NODE;

		if (isSuccess) {
			resultNode.findAllElements('param').forEach((XmlNode paramNode) =>
				_params.add(RpcParam.fromParamNode(paramNode))
			);
		}
		else {
			XmlElement valueNode = resultNode.children.single;
			XmlElement typeNode = valueNode.children.single;

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

  void _makeParams() {
    if (!isSuccess) {
      assert(_params.length < 2);
    }

    _params.forEach((Object param) {
      if (isSuccess)
        builder.element('param', nest: () {
          RpcParam.buildParam(builder, param);
        });
      else
        builder.element('value', nest: param);
    });
  }

	XmlElement _getResultNode() =>
		_root.children[1];
}
