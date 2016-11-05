//
// XCTestManifests.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

#if !os(macOS)
import XCTest
	public func allTests() -> [XCTestCaseEntry] {
		return [
			testCase(SmokeTests.allTests),
			testCase(ArrayTests.allTests),
			testCase(ByteArrayTests.allTests),
			testCase(DocumentTypesTests.allTests),
			testCase(PGTypeExtensionsTests.allTests),
			testCase(SerialTests.allTests),
			testCase(NumericTests.allTests),
			testCase(DatabaseManagerTests.allTests),
			testCase(PGModelTests.allTests)
		]
	}
#endif
