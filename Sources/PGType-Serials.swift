//
// PGType-Serials.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

/// An auto-incrementing 64-bit (signed) integer type.
public class PGBigSerial : PGTypeConvertible, ExpressibleByIntegerLiteral, Equatable {
	var value: Int
	public static func databaseType() -> PGType {
		return .bigSerial
	}
	public func databaseValue() -> String {
		return "\(value)"
	}
	public init(value: Int) {
		self.value = value
	}
	public required init(integerLiteral value: Int) {
		self.value = value
	}
}

/// An auto-incrementing 32-bit (signed) integer type.
public class PGSerial : PGTypeConvertible, ExpressibleByIntegerLiteral, Equatable {
	var value: Int32
	public static func databaseType() -> PGType {
		return .serial
	}
	public func databaseValue() -> String {
		return "\(value)"
	}
	public init(value: Int32) {
		self.value = value
	}
	public required init(integerLiteral value: Int32) {
		self.value = value
	}
}

/// An auto-incrementing 16-bit (signed) integer type.
public class PGSmallSerial : PGTypeConvertible, ExpressibleByIntegerLiteral, Equatable {
	var value: Int16
	public static func databaseType() -> PGType {
		return .smallSerial
	}
	public func databaseValue() -> String {
		return "\(value)"
	}
	public init(value: Int16) {
		self.value = value
	}
	public required init(integerLiteral value: Int16) {
		self.value = value
	}
}

public func ==(lhs: PGBigSerial, rhs: PGBigSerial) -> Bool {
	return lhs.value == rhs.value
}
public func ==(lhs: PGSerial, rhs: PGSerial) -> Bool {
	return lhs.value == rhs.value
}
public func ==(lhs: PGSmallSerial, rhs: PGSmallSerial) -> Bool {
	return lhs.value == rhs.value
}
