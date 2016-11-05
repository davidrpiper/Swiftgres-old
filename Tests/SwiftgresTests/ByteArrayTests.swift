//
// ByteArrayTests.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

import XCTest
@testable import Swiftgres

class ByteArrayTests: XCTestCase {
	func testByteArray() {
		let arrS: [Int8] = [1, 10, 100, -1]
		let arrU: [UInt8] = [1, 10, 100, 255]
		let byteS: PGByteArray = PGByteArray(arrS)
		let byteU: PGByteArray = PGByteArray(arrU)

		XCTAssertEqual(PGByteArray.databaseType(), .bytea)
		XCTAssertEqual(byteS, byteU)
		XCTAssertEqual(byteU.databaseValue(), "E'\\\\x010A64FF'")
		XCTAssertEqual(byteS.databaseValue(), "E'\\\\x010A64FF'")

		XCTAssertEqual(byteS.bytes(), byteU.bytes())
		XCTAssertEqual(byteS.bytes(), arrU)
	}

	func testEmptyByteArray() {
		let arrU: [UInt8] = []
		let arrS: [Int8] = []
		let str: String = "E'\\\\x'"

		let byteaU: PGByteArray = PGByteArray(arrU)
		let byteaS: PGByteArray = PGByteArray(arrS)
		XCTAssertEqual(arrU, byteaU.bytes())
		XCTAssertEqual(arrU, byteaS.bytes())
		XCTAssertEqual(byteaU, byteaS)
		XCTAssertEqual(byteaS.databaseValue(), str)
		XCTAssertEqual(byteaU.databaseValue(), str)
	}
}
