//
// PGModelTests.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

import XCTest
@testable import Swiftgres

// Test dry runs of PGModel methods
class PGModelTests: XCTestCase {

	private class EmptyModel: PGModel { }

	private class TestModelWithoutForeignKeys: PGModel {

		public static let TABLE_NAME = "tableName"

		public var integerField: PGKey<Int> = PGKey(1)
		public var stringField: PGKey<String> = PGKey("A")

		public var anotherInteger: Int = 3
		public var anotherString: String = "B"

		override class func tableName() -> String {
			return TABLE_NAME
		}
	}

	// Complete white-box test (and therefore highly brittle)
	func testSaveInsert() {
		let model = TestModelWithoutForeignKeys()
		let retInsert = model._save()

		XCTAssertEqual(retInsert.0, .successful)
		XCTAssertEqual(retInsert.1.count, 2)
		XCTAssertEqual(retInsert.1[0].columnName, "integerField")
		XCTAssertEqual(retInsert.1[0].value, "1")
		XCTAssertEqual(retInsert.1[1].columnName, "stringField")
		XCTAssertEqual(retInsert.1[1].value, "'A'")
		XCTAssertNotNil(retInsert.2)
		XCTAssertEqual(retInsert.2!.preparedStatementName, "INSERT_tableName_integerField_stringField")
		XCTAssertEqual(retInsert.2!.preparedStatement, "INSERT INTO tableName (integerField, stringField) VALUES ($1, $2) RETURNING id;")
		XCTAssertEqual(retInsert.2!.nParams, Int32(2))

		let retUpdate = model._save()

		XCTAssertEqual(retUpdate.0, .successful)
		XCTAssertEqual(retUpdate.1.count, 2)
		XCTAssertEqual(retUpdate.1[0].columnName, "integerField")
		XCTAssertEqual(retUpdate.1[0].value, "1")
		XCTAssertEqual(retUpdate.1[1].columnName, "stringField")
		XCTAssertEqual(retUpdate.1[1].value, "'A'")
		XCTAssertNotNil(retUpdate.2)
		XCTAssertEqual(retUpdate.2!.preparedStatementName, "UPDATE_tableName_integerField_stringField")
		XCTAssertEqual(retUpdate.2!.preparedStatement, "UPDATE tableName SET integerField = $1, stringField = $2 WHERE id = $3;")
		XCTAssertEqual(retUpdate.2!.nParams, Int32(3))
	}

}
