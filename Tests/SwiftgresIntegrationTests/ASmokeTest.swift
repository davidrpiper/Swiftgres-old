//
// ASmokeTest.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

import XCTest
@testable import Swiftgres

class ASmokeTest: SwiftgresIntegrationTest {
	func test_DatabaseSmoke() {
		XCTAssertEqual(connection!.result, .successful(.successful([:])))
	}
}
