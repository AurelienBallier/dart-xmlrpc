library multiconverter;

class Multiconverter {
	final Map<Object, Function> _converters;

	Multiconverter(this._converters) {
	}

	Function getConverter(Object value) {
		//Make sure we avoid sub types List<int>, Map<String, int>...
		String _type = value.runtimeType.toString().split('<')[0];

		if(_converters.containsKey(value)){
			return _converters[value];
		}else if(_converters.containsKey(_type)){
			return _converters[_type];
		}else{
			return converter = () {};
		}

		return converter;
	}
}
