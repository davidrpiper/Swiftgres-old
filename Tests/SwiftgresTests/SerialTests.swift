//
// SerialTests.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

import XCTest
@testable import Swiftgres

// The smoke test. We require Int to be 64 bits.
class SerialTests: XCTestCase {

	// Test the PGSerial class
	func testSerial() {
		let serial1: PGSerial = 1
		let serial2: PGSerial = PGSerial(value: 1)

		XCTAssertEqual(PGSerial.databaseType(), .serial)
		XCTAssertEqual(serial1.databaseValue(), "1")
		XCTAssertEqual(serial2.databaseValue(), "1")
		XCTAssertEqual(serial1, serial2)
	}

	// Test the PGBigSerial class
	func testBigSerial() {
		let serial1: PGBigSerial = 1
		let serial2: PGBigSerial = PGBigSerial(value: 1)

		XCTAssertEqual(PGBigSerial.databaseType(), .bigSerial)
		XCTAssertEqual(serial1.databaseValue(), "1")
		XCTAssertEqual(serial2.databaseValue(), "1")
		XCTAssertEqual(serial1, serial2)
	}

	// Test the PGSmallSerial class
	func testSmallSerial() {
		let serial1: PGSmallSerial = 1
		let serial2: PGSmallSerial = PGSmallSerial(value: 1)

		XCTAssertEqual(PGSmallSerial.databaseType(), .smallSerial)
		XCTAssertEqual(serial1.databaseValue(), "1")
		XCTAssertEqual(serial2.databaseValue(), "1")
		XCTAssertEqual(serial1, serial2)
	}
}
