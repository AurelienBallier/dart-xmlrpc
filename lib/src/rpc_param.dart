part of xmlrpc;

class RpcParam {
	/**
	 * The date format for the `<dateTime.iso8601 />` tag.
	 */
	static String DATE_FORMAT = 'yMdTHH:mm:ss';

	static final _converter_in = new Multiconverter({
		'boolean': (XmlNode elem) =>
			elem.text == 'true',

		'int': (XmlNode elem) =>
			int.parse(elem.text),

		'i4': (XmlNode elem) =>
			int.parse(elem.text),

		'double': (XmlNode elem) =>
			double.parse(elem.text),

		ISO_8601_NODE: (XmlNode elem) =>
			DateTime.parse(elem.text),

		'nil': (XmlNode elem) =>
			null,

		'base64': (XmlNode elem) =>
			CryptoUtils.base64StringToBytes(elem.text),

		 // <array><data><value>1</value><value>2</value></data></array>
		'array': (XmlNode elem) {
			var result = [];
			XmlNode dataNode = elem.children.single;

			dataNode.children.forEach((XmlNode elem) {
				if(elem.nodeType.toString() == 'XmlNodeType.ELEMENT'){
					if(elem.children.length > 0){
						result.add(fromXmlElement(elem.children.single));
					}else{
						result.add("");
					}
				}
			});

			return result;
		},

		 // <struct><member><name>some</name><value><string>value</string></value></member></struct>
		'struct': (XmlNode elem) {
			var result = {};

			elem.children.forEach((XmlNode member) {
				var name = (member.query(NAME_NODE).single as XmlNode).text;
				XmlNode valueNode = member.query(VALUE_NODE).single;

				result[name] = fromXmlElement(valueNode.children.single);
			});

			return result;
		},

		'string': (XmlNode elem) =>
			elem.text
	});

	static final _converter_out = new Multiconverter({
		"int": (var builder, int value) {
			builder.element('int', nest: value.toString());
		},

		"bool": (var builder, bool value) {
			builder.element('boolean', nest: value.toString());
		},

		"double": (var builder, double value) {
			builder.element('double', nest: value.toString());
		},

		"DateTime": (var builder, DateTime value) {
			builder.element(ISO_8601_NODE, nest: new DateFormat(DATE_FORMAT).format(value));
		},

		"new List<int>().runtimeType": (var builder, List<int> binaryData) {
			builder.element(BASE64_NODE, nest: CryptoUtils.bytesToBase64(binaryData));
		},

		"String": (var builder, String value) {
			builder.element('string', nest: value);
		},

		"List": (var builder, List list) {
			builder.element(ARRAY_NODE, nest: (){
				builder.element(DATA_NODE, nest: (){
					list.forEach((Object value) {
						RpcParam.buildParam(builder, value);
					});
				});
			});
		},

		"Map": (Map map) {
			builder.element(STRUCT_NODE, nest: (){
				map.keys.forEach((Object key) {
					builder.element(MEMBER_NODE, nest: (){
						builder.element(NAME_NODE, nest: key.toString());
						RpcParam.buildParam(builder, map[key]);
					});
				});
			});
		},

		"null": (bool value) {
			builder.element('nil', nest: (){});
		}
	});

	/**
	 * Returns an Object representation for a value from an XML node which wraps an XML-RPC param.
	 *
	 * The node should have a structure like:
	 *
	 *     <param>
	 *         <value>...</value>
	 *     </param>
	 */
	static Object fromParamNode(XmlNode node) {
		assert(node.name.toString() == 'param');

		XmlNode valueNodeElem = node.children[1];

		assert(valueNodeElem.name.toString() == 'value');

		return fromXmlElement(valueNodeElem.children.single);
	}

	/**
	 * Returns an Object representation for a value from an XML node.
	 *
	 * The node should have a structure like:
	 *
	 *     <int>...</int>
	 */
	static Object fromXmlElement(XmlNode node) {
		//If there is no type it's a String
		if(node.runtimeType == XmlText){
			return node.text;
		}

		Function converter = _converter_in.getConverter(node.name.toString());

		assert(converter != null);

		return converter(node);
	}

	/**
	 * Modify xml builder for the value.
	 */

	static void buildParam(var builder, Object value) {
		Function converter = _converter_out.getConverter(value);

		assert(converter != null);

		builder.element(VALUE_NODE, nest: () {
			converter(builder, value);
		});
	}
}
