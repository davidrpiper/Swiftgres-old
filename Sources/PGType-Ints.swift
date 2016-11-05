//
// PGType-Ints.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

extension Int : PGTypeConvertible {
	public static func databaseType() -> PGType {
		return .bigInt
	}
	public func databaseValue() -> String {
		return "\(self)"
	}
}

extension Int64 : PGTypeConvertible {
	public static func databaseType() -> PGType {
		return .bigInt
	}
	public func databaseValue() -> String {
		return "\(self)"
	}
}

extension Int32 : PGTypeConvertible {
	public static func databaseType() -> PGType {
		return .integer
	}
	public func databaseValue() -> String {
		return "\(self)"
	}
}

extension Int16 : PGTypeConvertible {
	public static func databaseType() -> PGType {
		return .smallInt
	}
	public func databaseValue() -> String {
		return "\(self)"
	}
}

extension Int8 : PGTypeConvertible {
	public static func databaseType() -> PGType {
		return .smallInt
	}
	public func databaseValue() -> String {
		return "\(self)"
	}
}
