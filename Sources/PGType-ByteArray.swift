//
// PGType-ByteArray.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

/// A class for representing the Postgres bytea type. Note we cannot just extend
/// NSData as this would require importing Foundation.
public class PGByteArray : PGTypeConvertible, Equatable {
	fileprivate var byteArray: [UInt8] = []

	public init(_ bytes: [UInt8]) {
		byteArray = bytes
	}
	public init(_ bytes: [Int8]) {
		byteArray = bytes.map{ UInt8(bitPattern: $0) }
	}
	public func bytes() -> [UInt8] {
		return byteArray
	}
	public static func databaseType() -> PGType {
		return .bytea
	}
	public func databaseValue() -> String {
		let prefix = "E'\\\\x"
		let suffix = "'"
		let hex1 = byteArray.map{ String($0, radix: 16, uppercase: true) }
		let hex2 = hex1.map{ $0.characters.count < 2 ? "0" + $0 : $0 }
		let hex = hex2.joined()
		return prefix + hex + suffix
	}
}

public func ==(lhs: PGByteArray, rhs: PGByteArray) -> Bool {
	return lhs.byteArray == rhs.byteArray
}
