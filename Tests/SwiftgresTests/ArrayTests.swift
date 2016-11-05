//
// ArrayTests.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

import XCTest
@testable import Swiftgres

// Tests various manifestations of the Postgres array type.
class ArrayTests: XCTestCase {

	let intArray: [Int] = [1, 2, 3]
	let strArray: [String] = ["ab,c", "de,f", "gh,i"]

	let intArrayString = "{\"1\",\"2\",\"3\"}"
	let strArrayString = "{\"ab,c\",\"de,f\",\"gh,i\"}"

	func testDatabaseType() {
		XCTAssertEqual(PGArray<Int>.databaseType(), .array(.bigInt, nil))
		XCTAssertEqual(PGArray<PGArray<Int>>.databaseType(), .array(.array(.bigInt, nil), nil))
		XCTAssertEqual(PGArray<PGArray<PGArray<Int>>>.databaseType(), .array(.array(.array(.bigInt, nil), nil), nil))
	}

	func test1DArrays() {
		let arr1: PGArray<Int> = PGArray(intArray)
		let arr2: PGArray<String> = PGArray(strArray)
		XCTAssertEqual(arr1.databaseValue(), "'" + intArrayString + "'")
		XCTAssertEqual(arr2.databaseValue(), "'" + strArrayString + "'")
	}

	func test2DArrays() {
		let arr1: PGArray<Int> = PGArray(intArray)
		let arr2: PGArray<String> = PGArray(strArray)
		let twoDimensionalArr1 = PGArray([arr1, arr1, arr1])
		let twoDimensionalArr2 = PGArray([arr2, arr2, arr2])

		let stringOf2DIntArr = "'{" + intArrayString + "," + intArrayString + "," + intArrayString + "}'"
		let stringOf2DStrArr = "'{" + strArrayString + "," + strArrayString + "," + strArrayString + "}'"

		XCTAssertEqual(twoDimensionalArr1.databaseValue(), stringOf2DIntArr)
		XCTAssertEqual(twoDimensionalArr2.databaseValue(), stringOf2DStrArr)
	}

	func test3DArrays() {
		let arr1: PGArray<Int> = PGArray(intArray)
		let arr2: PGArray<String> = PGArray(strArray)
		let twoDimensionalArr1 = PGArray([arr1, arr1, arr1])
		let twoDimensionalArr2 = PGArray([arr2, arr2, arr2])
		let threeDimensionalArr1 = PGArray([twoDimensionalArr1, twoDimensionalArr1, twoDimensionalArr1])
		let threeDimensionalArr2 = PGArray([twoDimensionalArr2, twoDimensionalArr2, twoDimensionalArr2])

		let stringOf2DIntArr = "{" + intArrayString + "," + intArrayString + "," + intArrayString + "}"
		let stringOf2DStrArr = "{" + strArrayString + "," + strArrayString + "," + strArrayString + "}"
		let stringOf3DIntArr = "'{" + stringOf2DIntArr + "," + stringOf2DIntArr + "," + stringOf2DIntArr + "}'"
		let stringOf3DStrArr = "'{" + stringOf2DStrArr + "," + stringOf2DStrArr + "," + stringOf2DStrArr + "}'"
		
		XCTAssertEqual(threeDimensionalArr1.databaseValue(), stringOf3DIntArr)
		XCTAssertEqual(threeDimensionalArr2.databaseValue(), stringOf3DStrArr)
	}
}
