//
// SmokeTests.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

import XCTest
@testable import Swiftgres

class NumericTests: XCTestCase {

	// Test the databaseType() method
	func testDatabaseType() {
		XCTAssertEqual(PGNumeric.databaseType(), .numeric(0, 0))
	}

	// Test all initialisers
	func testInitialisers() {
		let numeric1: PGNumeric = "1.2"
		let numeric2: PGNumeric = PGNumeric(number: "1.2")
		let numeric3: PGNumeric = PGNumeric(integerPart: "1", fractionalPart: "2")

		XCTAssertEqual(numeric1, numeric2)
		XCTAssertEqual(numeric1, numeric3)
		XCTAssertEqual(numeric2, numeric3)

		let numeric4: PGNumeric = PGNumeric(number: "1")
		let numeric5: PGNumeric = PGNumeric(integerPart: "1", fractionalPart: nil)
		let numeric6: PGNumeric = "1"
		let numeric7: PGNumeric = PGNumeric(integerPart: "1", fractionalPart: "0")

		XCTAssertEqual(numeric4, numeric5)
		XCTAssertEqual(numeric4, numeric6)
		XCTAssertEqual(numeric5, numeric6)
		XCTAssertNotEqual(numeric4, numeric7)
		XCTAssertNotEqual(numeric5, numeric7)
		XCTAssertNotEqual(numeric6, numeric7)
	}

	// Happy path simple cases for databaseValue()
	func testDatabaseValueWhole() {
		let numeric1: PGNumeric = "1.2"
		let numeric2: PGNumeric = PGNumeric(number: "1.2")
		let numeric3: PGNumeric = PGNumeric(integerPart: "1", fractionalPart: "2")
		let numeric4: PGNumeric = PGNumeric(number: "1")
		let numeric5: PGNumeric = PGNumeric(integerPart: "1", fractionalPart: nil)
		let numeric6: PGNumeric = "1"
		let numeric7: PGNumeric = PGNumeric(integerPart: "1", fractionalPart: "0")
		XCTAssertEqual(numeric1.databaseValue(), "1.2")
		XCTAssertEqual(numeric2.databaseValue(), "1.2")
		XCTAssertEqual(numeric3.databaseValue(), "1.2")
		XCTAssertEqual(numeric4.databaseValue(), "1")
		XCTAssertEqual(numeric5.databaseValue(), "1")
		XCTAssertEqual(numeric6.databaseValue(), "1")
		XCTAssertEqual(numeric7.databaseValue(), "1.0")
	}

	// Edge cases for databaseValue():
	// 1 - Just enough fractional digits
	// 2 - Too many fractional digits
	// 3 - Just enough digits with no fractional digits
	// 4 - Too many digits with no fractional digits
	// 5 - Just enough digits with just enough fractional digits
	// 6 - Just enough digits (before trim) with too many fractional digits
	// 7 - Just enough digits (after trim) with too many fractional digits
	// 8 - Too many digits with just enough fractional digits
	// 9 - Too many digits (before trim) with too many fractional digits
	// 10 - Too many digits (after trim) with too many fractional digits
	func testDatabaseValueTruncatedAndEdgeCases() {

		let fullyPackedNumericString: String = fullyPacked()

		// 1
		var string1: String = "0."
		for _ in 0..<PGType.maxNumericPrecisionAndScale().1 {
			string1.append("1")
		}
		let numeric1: PGNumeric = PGNumeric(number: string1)
		XCTAssertEqual(numeric1.databaseValue(), string1)

		// 2
		let string2 = string1 + "1"
		let numeric2: PGNumeric = PGNumeric(number: string2)
		XCTAssertNotEqual(numeric2.databaseValue(), string2)
		XCTAssertEqual(numeric2.databaseValue(), string1)

		// 3
		var string3: String = ""
		for _ in 0..<PGType.maxNumericPrecisionAndScale().0 {
			string3.append("1")
		}
		let numeric3: PGNumeric = PGNumeric(number: string3)
		XCTAssertEqual(numeric3.databaseValue(), string3)

		// 4
		let string4 = string3 + "1"
		let numeric4: PGNumeric = PGNumeric(number: string4)
		XCTAssertNotEqual(numeric4.databaseValue(), string4)
		XCTAssertEqual(numeric4.databaseValue(), string3)

		// 5
		let string5: String = fullyPackedNumericString
		let numeric5: PGNumeric = PGNumeric(number: string5)
		XCTAssertEqual(numeric5.databaseValue(), string5)

		// 6
		var string6: String = string5 + "9"
		string6.remove(at: string6.startIndex)
		let numeric6: PGNumeric = PGNumeric(number: string6)
		XCTAssertNotEqual(numeric6.databaseValue(), string6)
		string6.remove(at: string6.index(before: string6.endIndex))
		XCTAssertEqual(numeric6.databaseValue(), string6)

		// 7
		let string7 = string5 + "9"
		let numeric7: PGNumeric = PGNumeric(number: string7)
		XCTAssertNotEqual(numeric7.databaseValue(), string7)
		XCTAssertEqual(numeric7.databaseValue(), string5)

		// 8
		var string8 = fullyPackedNumericString
		string8 = "9" + string8
		let numeric8: PGNumeric = PGNumeric(number: string8)
		XCTAssertNotEqual(numeric8.databaseValue(), string8)
		string8.remove(at: string8.startIndex)
		XCTAssertEqual(numeric8.databaseValue(), string8)

		// 9
		var string9 = fullyPackedNumericString
		string9 = string9 + "9"
		let numeric9: PGNumeric = PGNumeric(number: string9)
		XCTAssertNotEqual(numeric9.databaseValue(), string9)
		string9.remove(at: string9.index(before: string9.endIndex))
		XCTAssertEqual(numeric9.databaseValue(), string9)

		// 10
		var string10 = fullyPackedNumericString
		string10 = "9" + string10 + "9"
		let numeric10: PGNumeric = PGNumeric(number: string10)
		XCTAssertNotEqual(numeric10.databaseValue(), string10)
		string10.remove(at: string10.startIndex)
		string10.remove(at: string10.index(before: string10.endIndex))
		XCTAssertEqual(numeric10.databaseValue(), string10)
	}

	func fullyPacked() -> String {
		var str: String = "."
		for _ in 0..<PGType.maxNumericPrecisionAndScale().1 {
			str.append("1")
		}
		for _ in 0..<PGType.maxNumericPrecisionAndScale().0 - PGType.maxNumericPrecisionAndScale().1 {
			str = "1" + str
		}
		return str
	}
}
