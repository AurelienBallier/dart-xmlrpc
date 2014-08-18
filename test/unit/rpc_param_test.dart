library rpc_param_test;

import 'package:unittest/unittest.dart';
import 'package:xmlrpc/xmlrpc.dart';
import 'package:xml/xml.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert' show UTF8;


main() {
	group('To XML', () {
		test('String', () {
		  XmlBuilder builder = new XmlBuilder();
			RpcParam.buildParam(builder, 'hello');

			expect(builder.build().toString(), equals('<value><string>hello</string></value>'));
		});

		test('int', () {
      XmlBuilder builder = new XmlBuilder();
			RpcParam.buildParam(builder, 5);

			expect(builder.build().toString(), equals('<value><int>5</int></value>'));
		});

		test('double', () {
      XmlBuilder builder = new XmlBuilder();
			RpcParam.buildParam(builder, 3.14159);

			expect(builder.build().toString(), equals('<value><double>3.14159</double></value>'));
		});

		test('null', () {
      XmlBuilder builder = new XmlBuilder();
			RpcParam.buildParam(builder, null);

			expect(builder.build().toString(), equals('<value><nil /></value>'));
		});

		test('bool', () {
      XmlBuilder builder = new XmlBuilder();
			RpcParam.buildParam(builder, true);
			expect(builder.build().toString(), equals('<value><boolean>true</boolean></value>'));

      builder = new XmlBuilder();
			RpcParam.buildParam(builder, false);
			expect(builder.build().toString(), equals('<value><boolean>false</boolean></value>'));
		});

		test('DateTime', () {
      XmlBuilder builder = new XmlBuilder();
			var now = new DateTime.now();
			RpcParam.buildParam(builder, now);
			var formatter = new DateFormat(RpcParam.DATE_FORMAT);

			expect(builder.build().toString(), equals('<value><dateTime.iso8601>${formatter.format(now)}</dateTime.iso8601></value>'));
		});

		test('Array', () {
      XmlBuilder builder = new XmlBuilder();
			RpcParam.buildParam(builder, [5, 'hello']);

			expect(builder.build().toString(), equals('<value><array><data><value><int>5</int></value><value><string>hello</string></value></data></array></value>'));
		});

		test('Map', () {
      XmlBuilder builder = new XmlBuilder();
			var map = new Map();

			map[5] = 'hello';
			map['there'] = 7;

			RpcParam.buildParam(builder, map);

			expect(builder.build().toString(), equals('<value><struct><member><name>5</name><value><string>hello</string></value></member><member><name>there</name><value><int>7</int></value></member></struct></value>'));
		});

		test('Base64', () {
      XmlBuilder builder = new XmlBuilder();
			var str = 'Just a test';
			var bytes = UTF8.encode(str);
			var base64 = CryptoUtils.bytesToBase64(bytes);

			RpcParam.buildParam(builder, bytes);

			expect(builder.build().toString(), equals('<value><base64>$base64</base64></value>'));
		});
	});

	group('From XML', () {
		test('String', () {
			var param = RpcParam.fromParamNode(parse('''
				<param>
					<value>
						<string>hello</string>
					</value>
				</param>
			''').rootElement);

			expect(param, isNotNull);
			expect(param, new isInstanceOf<String>());
			expect(param, equals('hello'));
		});

		test('null', () {
			var param = RpcParam.fromParamNode(parse('''
				<param>
					<value>
						<nil />
					</value>
				</param>
			''').rootElement);

			expect(param, isNull);
		});

		test('double', () {
			var param = RpcParam.fromParamNode(parse('''
				<param>
					<value>
						<double>-3.14159</double>
					</value>
				</param>
			''').rootElement);

			expect(param, new isInstanceOf<double>());
			expect(param, equals(-3.14159));
		});

		test('dateTime.iso8601', () {
			var param = RpcParam.fromParamNode(parse('''
				<param>
					<value>
						<dateTime.iso8601>19980717T14:08:55</dateTime.iso8601>
					</value>
				</param>
			''').rootElement);

			expect(param, new isInstanceOf<DateTime>());
			expect((param as DateTime).year, equals(1998));
			expect((param as DateTime).hour, equals(14));
		});

		test('int', () {
			var param = RpcParam.fromParamNode(parse('''
				<param>
					<value>
						<int>1</int>
					</value>
				</param>
			''').rootElement);

			expect(param, isNotNull);
			expect(param, new isInstanceOf<int>());
			expect(param, equals(1));

			param = RpcParam.fromParamNode(parse('''
				<param>
					<value>
						<i4>2</i4>
					</value>
				</param>
			''').rootElement);

			expect(param, isNotNull);
			expect(param, new isInstanceOf<int>());
			expect(param, equals(2));
		});

		test('Array', () {
			var param = RpcParam.fromParamNode(parse('''
				<param>
					<value>
						<array>
							<data>
								<value><i4>1404</i4></value>
								<value><string>Something here</string></value>
								<value><boolean>true</boolean></value>
							</data>
						</array>
					</value>
				</param>
			''').rootElement);

			expect(param, isNotNull);
			expect(param, new isInstanceOf<List>());
			expect(param[0], new isInstanceOf<int>());
			expect(param[0], equals(1404));
			expect(param[1], new isInstanceOf<String>());
			expect(param[1], equals('Something here'));
			expect(param[2], new isInstanceOf<bool>());
			expect(param[2], equals(true));
		});

		test('Map', () {
			var param = RpcParam.fromParamNode(parse('''
				<param>
					<value>
						<struct>
							<member>
								<name>foo</name>
								<value><i4>1</i4></value>
							</member>
							<member>
								<name>bar</name>
								<value><string>Another value</string></value>
							</member>
						</struct>
					</value>
				</param>
			''').rootElement);

			expect(param, isNotNull);
			expect(param, new isInstanceOf<Map>());
			expect(param['foo'], new isInstanceOf<int>());
			expect(param['foo'], equals(1));
			expect(param['bar'], new isInstanceOf<String>());
			expect(param['bar'], equals('Another value'));
		});

		test('Base64', () {
			var str = 'Some data';
			var bytes = UTF8.encode(str);
			var base64 = CryptoUtils.bytesToBase64(bytes);

			var param = RpcParam.fromParamNode(parse('''
				<param>
					<value>
						<base64>
							$base64
						</base64>
					</value>
				</param>
			''').rootElement);

			expect(param, isNotNull);
			expect(param, new isInstanceOf<List<int>>());
			expect(UTF8.decode(param), equals(str));
		});
	});
}