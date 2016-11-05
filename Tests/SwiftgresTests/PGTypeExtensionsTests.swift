//
// PGTypeExtensionsTests.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

import XCTest
@testable import Swiftgres

class PGTypeExtensionsTests: XCTestCase {

	// Bool extension
	func testBools() {
		var bool: Bool = true
		XCTAssertEqual(Bool.databaseType(), .boolean)
		XCTAssertEqual(bool.databaseValue(), "TRUE")
		bool = false
		XCTAssertEqual(bool.databaseValue(), "FALSE")
	}

	// Integer extensions
	func testInts() {
		let int: Int = 1
		let int64: Int64 = 1
		let int32: Int32 = 1
		let int16: Int16 = 1
		let int8: Int8 = 1

		XCTAssertEqual(Int.databaseType(), .bigInt)
		XCTAssertEqual(Int64.databaseType(), .bigInt)
		XCTAssertEqual(Int32.databaseType(), .integer)
		XCTAssertEqual(Int16.databaseType(), .smallInt)
		XCTAssertEqual(Int8.databaseType(), .smallInt)

		XCTAssertEqual(int.databaseValue(), "1")
		XCTAssertEqual(int64.databaseValue(), "1")
		XCTAssertEqual(int32.databaseValue(), "1")
		XCTAssertEqual(int16.databaseValue(), "1")
		XCTAssertEqual(int8.databaseValue(), "1")
	}

	// Floating point extensions
	func testFloatsAndDoubles() {
		let nanString = "'nan'"
		let infString = "'infinity'"
		let ninfString = "'-infinity'"

		let float: Float = 1.532
		let double: Double = 1.532532

		XCTAssertEqual(Float.databaseType(), .real)
		XCTAssertEqual(Double.databaseType(), .doublePrecision)

		XCTAssert(float.databaseValue().hasPrefix("1.532"))
		XCTAssert(double.databaseValue().hasPrefix("1.532532"))

		let nanF: Float = Float.nan
		let nanD: Double = Double.nan

		XCTAssertEqual(nanF.databaseValue().lowercased(), nanString)
		XCTAssertEqual(nanD.databaseValue().lowercased(), nanString)

		let infF: Float = Float.infinity
		let infD: Double = Double.infinity
		let ninfF: Float = infF.negated()
		let ninfD: Double = infD.negated()

		XCTAssertEqual(infF.databaseValue().lowercased(), infString)
		XCTAssertEqual(infD.databaseValue().lowercased(), infString)
		XCTAssertEqual(ninfF.databaseValue().lowercased(), ninfString)
		XCTAssertEqual(ninfD.databaseValue().lowercased(), ninfString)
	}

	// String extension
	func testStrings() {
		var str: String = "ABC"
		XCTAssertEqual(String.databaseType(), .text)
		XCTAssertEqual(str.databaseValue(), "'" + str + "'")
		str = ""
		XCTAssertEqual(str.databaseValue(), "''")
		str = "'ab'cd'ef'"
		XCTAssertEqual(str.databaseValue(), "'\'ab\'cd\'ef\''")
	}
}
