library rpc_request_test;

import 'package:unittest/unittest.dart';
import 'package:xmlrpc/xmlrpc.dart';
import 'package:xml/xml.dart';


main() {
	test('Name and structure', () {
		var req = new RpcRequest.fromText(
			'''
				<methodCall>
					<methodName>blah</methodName>
					<params />
				</methodCall>
			'''
		);

		expect(req.method, equals('blah'));
		expect(req.toString(), equals('<?xml version="1.0"?><methodCall><methodName>blah</methodName><params /></methodCall>'));
	});

	test('Parse string parameter', () {
		var req = new RpcRequest.fromText(
			'''
				<methodCall>
					<methodName>blah</methodName>
					<params>
						<param>
							<value>
								<string>hello</string>
							</value>
						</param>
						<param>
							<value>
								<int>4</int>
							</value>
						</param>
					</params>
				</methodCall>
			'''
		);

		expect(req, hasLength(2));
		expect(req[0], new isInstanceOf<String>());
		expect(req[0], equals('hello'));
		expect(req[1], new isInstanceOf<int>());
		expect(req[1], equals(4));
	});

	test('From scratch', () {
		var req = new RpcRequest();

		req.method = 'blah2';
		req.addParam(2);
		req.addParam('yep');
		req.addParam({'hello': 'there'});

		expect(req.toString(), equals('<?xml version="1.0"?><methodCall><methodName>blah2</methodName><params><param><value><int>2</int></value></param><param><value><string>yep</string></value></param><param><value><struct><member><name>hello</name><value><string>there</string></value></member></struct></value></param></params></methodCall>'));
	});
}