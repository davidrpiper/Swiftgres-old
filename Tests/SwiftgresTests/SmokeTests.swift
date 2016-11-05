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

// The smoke test. We require Int to be 64 bits.
class SmokeTests: XCTestCase {
	func testSmoke() {
		XCTAssertEqual(MemoryLayout<Int>.size, 8)
	}
}
