//
// PGType-Floats.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

/// This type is designed to be imprecise. If you need a guarantee of digits
/// before and after the decimal point, use Postgres' Numeric type.
extension Float : PGTypeConvertible {
	public static func databaseType() -> PGType {
		return .real
	}
	public func databaseValue() -> String {
		if self.isFinite {
			return "\(self)"
		}
		if self.isInfinite && self < 0 {
			return "'-infinity'"
		}
		else if self.isInfinite {
			return "'infinity'"
		}
		return "'NaN'"
	}
}

/// This type is designed to be imprecise. If you need a guarantee of digits
/// before and after the decimal point, use Postgres' Numeric type.
extension Double : PGTypeConvertible {
	public static func databaseType() -> PGType {
		return .doublePrecision
	}
	public func databaseValue() -> String {
		if self.isFinite {
			return "\(self)"
		}
		if self.isInfinite && self < 0 {
			return "'-infinity'"
		}
		else if self.isInfinite {
			return "'infinity'"
		}
		return "'NaN'"
	}
}
