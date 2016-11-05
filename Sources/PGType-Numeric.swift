//
// PGType-Numeric.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

/// Postgres' Numeric type is designed to be exact. It has the following fields:
/// scale - the number of digits after the decimal point (maximum of 16383)
/// precision - the total number of digits in the number (maximum of 147455)
/// This implementation allows (and assumes) maximum scale and precision.
///
/// In cases where the the provided number has a fractional part with more
/// digits than the maximum scale, the least significant digits will be truncated.
/// In cases where the total number of digits exceeds the maximum precision, the
/// fractional part will be calculated first, allowing the maximum possible
/// number of fractional digits. The integer part will then be truncated (if
/// required) from the most significant digit.
///
/// For example, the number:
/// "123[... 131071 digits ...].[... 16381 digits ...]123"
/// will be resolved to:
/// "3[... 131071 digits ...].[... 16381 digits ...]12"
///
/// Note: As a reference implementation of this Postgres type, this class
/// deliberately does not allow conversion from Double or Float as these types
/// are inherently inexact.
public struct PGNumeric : PGTypeConvertible, ExpressibleByStringLiteral, Equatable {
	let integerPart: String
	let fractionalPart: String?

	/// Does not validate that Strings are only digits. Incorrect String formats
	/// will surface as database transaction errors.
	public init(integerPart: String, fractionalPart: String?) {
		self.integerPart = integerPart
		self.fractionalPart = fractionalPart
	}

	public init(stringLiteral value: String) {
		self.init(number: value)
	}
	public init(extendedGraphemeClusterLiteral value: String) {
		self.init(number: value)
	}
	public init(unicodeScalarLiteral value: String) {
		self.init(number: value)
	}

	/// Takes a single number of the form "123" or "12.321".
	/// Does not validate that Strings are only digits. Incorrect String formats
	/// will surface as database transaction errors.
	public init(number: String) {
		let arr = number.components(separatedBy: ".")
		switch arr.count {
		case 1:
			integerPart = arr[0]
			fractionalPart = nil
		case 2:
			integerPart = arr[0]
			fractionalPart = arr[1]
		default:
			integerPart = "0"
			fractionalPart = "0"
		}
	}

	public static func databaseType() -> PGType {
		return .numeric(0, 0)
	}

	public func databaseValue() -> String {
		let maximum: (precision: Int, scale: Int) = PGType.maxNumericPrecisionAndScale()

		guard let after = fractionalPart else {
			let range = integerPart.startIndex..<integerPart.index(integerPart.startIndex, offsetBy: min(maximum.precision, integerPart.characters.count))
			return integerPart[range]
		}

		let afterTrimRange = after.startIndex..<after.index(after.startIndex, offsetBy: min(maximum.scale, after.characters.count))
		let afterTrimmed = after[afterTrimRange]

		let remaining = maximum.precision - afterTrimmed.characters.count

		let beforeTrimRange = integerPart.index(integerPart.startIndex, offsetBy: max(0, integerPart.characters.count - remaining))..<integerPart.endIndex
		let beforeTrimmed = integerPart[beforeTrimRange]
		return beforeTrimmed + "." + afterTrimmed
	}
}

/// The Postgres decimal type is equivalent to the numeric type.
typealias PGDecimal = PGNumeric

public func ==(lhs: PGNumeric, rhs: PGNumeric) -> Bool {
	return lhs.integerPart == rhs.integerPart && lhs.fractionalPart == rhs.fractionalPart
}
