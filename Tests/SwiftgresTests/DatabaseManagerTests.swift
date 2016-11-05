//
// DatabaseManagerTests.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

import XCTest
@testable import Swiftgres

/*
class TestNoDBManager : PGDatabaseManager {
	override public func dataModel() -> [PGDataModel.Type] {
		return []
	}
}
*/

/*
fileprivate class TestManager : PGDatabaseManager {
	override public func dataModel() -> [PGDataModel.Type] {
		return [PGModel.self]
	}
}
*/

typealias TestManager = PGDatabaseManager

/// The PGDatabaseManager tests that can be run without a fully integrated environment.
/// See IntegrationTests for more.
class DatabaseManagerTests: XCTestCase {

	// Commented out until Swfit compiler stops segfaulting on TestManager.
	// For now PGDatabaseManager actually returns a single type in its dataModel method.
	// Test the failure case when no DB is required
	/*
	func testNoDatabaseRequired() {
		let manager: PGDatabaseManager = PGDatabaseManager()
		let result = manager.connect([])
		XCTAssertEqual(result, .unnecessary)

		let myManager: TestNoDBManager = TestNoDBManager()
		let myResult = myManager.connect([])
		XCTAssertEqual(myResult, .unnecessary)
	}
	*/

	// Test the failure case when we have a double-up in parameters
	func testDoubleParameterFailure() {

		// Totally invalid anyway
		let manager: TestManager = TestManager()
		let result = manager.connect([.host("example.com"), .host("example.com")])
		XCTAssertEqual(result, .failed(""))

		// Valid but two password parameters
		let manager2: TestManager = TestManager()
		let params: [PGConnectionParameter] = [
			.user("admin"),
			.password("password"),
			.host("example.com"),
			.port(5432),
			.dbName("name"),
			.password("admin")
		]
		let result2 = manager2.connect(params)
		XCTAssertEqual(result2, .failed(""))
	}
}
