//
// DocumentTypesTests.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

import XCTest
@testable import Swiftgres

class DocumentTypesTests: XCTestCase {

	// Simple test as PGJson does no validation (it's handled by the jsonb Postgres type)
	func testJsonb() {
		let jsonStr: String = "{\n\t\"array\": [1, 2, 3]\n}"
		let json = PGJsonb(fromString: jsonStr)
		XCTAssertEqual(PGJsonb.databaseType(), .jsonb)
		XCTAssertEqual(json.databaseValue(), "'" + jsonStr + "'")
		XCTAssertEqual(json.getContent(), jsonStr)
	}

	// Simple test as PGJson does no validation (it's handled by the json Postgres type)
	func testJson() {
		let jsonStr: String = "{\n\t\"array\": [1, 2, 3]\n}"
		let json = PGJson(fromString: jsonStr)
		XCTAssertEqual(PGJson.databaseType(), .json)
		XCTAssertEqual(json.databaseValue(), "'" + jsonStr + "'")
		XCTAssertEqual(json.getContent(), jsonStr)
	}

	// Simple test as PGXml does no validation (it's handled by the xml Postgres type)
	func testXml() {
		let xmlStr: String = "<node>content</node>"
		let xml = PGXml(fromString: xmlStr)
		XCTAssertEqual(PGXml.databaseType(), .xml)
		XCTAssertEqual(xml.databaseValue(), "'" + xmlStr + "'")
		XCTAssertEqual(xml.getContent(), xmlStr)
	}
}
