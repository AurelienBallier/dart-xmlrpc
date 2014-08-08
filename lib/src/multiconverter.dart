library multiconverter;

class Multiconverter {
	final Map<Object, Function> _converters;

	Multiconverter(this._converters) {
	}

	Function getConverter(Object value) {
		var converter = _converters[value];

		if (converter == null)
			converter = _converters[value.runtimeType.toString()];

		if (converter == null)
			converter = () {};

		return converter;
	}
}
