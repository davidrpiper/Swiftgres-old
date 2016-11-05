//
// PGType.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

import Foundation

/// A protocol to allow normal Swift types to be stored in a Postgres DB.
/// Extend any type with this protocol and it will be available for use in
/// your data model.
/// Swiftgres extends many basic Swift types on your behalf. Have a look at their
/// implementations before you write your own PGTypes.
public protocol PGTypeConvertible/*: Equatable*/ {

	/// Returns the Postgres type that will be used to represent this class.
	static func databaseType() -> PGType

	/// Returns the raw SQL characters that would be used to insert this object
	/// into the database. E.g. "1", "1.0001", or "a varchar". Note in the last
	/// example that any quotation marks expected by SQL will be provided for you.
	func databaseValue() -> String
}

/// An enum for all PostgreSQL native types. Where values can be provided, e.g
/// "varchar(n)", they should be provided as associated values.
///
/// Note that Swiftgres does not provide Swift types corresponding to all the
/// possible Postgres types here, only the most common or best practice ones.
/// For example character(n) is not implemented in Swift as text can do all the
/// same things, plus more, with no performance impact.
public enum PGType : Equatable {
	case boolean
	case smallInt
	case integer
	case bigInt
	case real
	case doublePrecision
	case smallSerial
	case serial
	case bigSerial
	case money

	/// (Precision, Scale). Values of 0 imply the maximum possible.
	case numeric(UInt, UInt)

	/// Varchar(0) implies a string of any length. Char(0) converts to Char(1).
	/// Text is a Postgres extension equivalent to Varchar(0).
	/// Char has no performance or memory advantage over Varchar in Postgres.
	case varchar(UInt)
	case character(UInt)
	case text

	/// Accepts either binary string format.
	case bytea

	/// Precision can be from 0-6. Nil implies no bound on precision (default).
	///
	/// TimestampWithTimeZone stores the Postgres Epoch time converted to UTC.
	/// If you don't append a time zone modifier for a TimestampWithTimeZone on
	/// input, the local time zone of the session is assumed. All computations
	/// are done with UTC timestamp values. If you may have to deal with more
	/// than on time zone, you should use TimestampWithTimeZone.
	case timestampWithoutTimeZone(Int?)
	case timestampWithTimeZone(Int?)
	case timeWithoutTimeZone(Int?)
	case timeWithTimeZone(Int?)
	case date
	case interval(PGIntervalField, Int?)

	/// Geometric types
	case point
	case line
	case lineSegment
	case box
	case path
	case polygon
	case circle

	/// Network types
	case cidr
	case inet
	case macAddress

	/// Bit vector types
	case bit(UInt)
	case bitVarying(UInt)

	/// Full text search types
	case textSearchVector
	case textSearchQuery

	/// UUID
	case uuid

	/// Structured data types
	case xml
	case json
	case jsonb

	/// Apply to any PGType to specify an array of length n.
	/// Apply recursively for multi-dimensional arrays.
	indirect case array(PGType, UInt?)

	/// The possible fields for the interval type.
	public enum PGIntervalField : String {
		case Year = "YEAR"
		case Month = "MONTH"
		case Day = "DAY"
		case Hour = "HOUR"
		case Minute = "MINUTE"
		case Second = "SECOND"
		case YearToMonth = "YEAR TO MONTH"
		case DayToHour = "DAY TO HOUR"
		case DayToMinute = "DAY TO MINUTE"
		case DayToSecond = "DAY TO SECOND"
		case HourToMinute = "HOUR TO MINUTE"
		case HourToSecond = "HOUR TO SECOND"
		case MinuteToSecond = "MINUTE TO SECOND"
	}

	public static func maxNumericPrecisionAndScale() -> (Int, Int) {
		return (147455, 16383)
	}

	public func dbString() -> String {
		switch self {
		case .boolean:
			return "boolean"
		case .smallInt:
			return "smallint"
		case .integer:
			return "integer"
		case .bigInt:
			return "bigint"
		case .real:
			return "real"
		case .doublePrecision:
			return "double precision"
		case .smallSerial:
			return "smallserial"
		case .serial:
			return "serial"
		case .bigSerial:
			return "bigserial"
		case .numeric(let precision, let scale):
			if precision == 0 && scale == 0 {
				return "numeric"
			}
			else if scale == 0 {
				return "numeric(\(precision))"
			}
			else {
				return "numeric(\(precision), \(scale))"
			}
		case .money:
			return "money"
		case .varchar(let n):
			if n == 0 || n == UInt.max {
				return "character varying"
			}
			else {
				return "character varying(\(n))"
			}
		case .character(let n):
			if n == 0 {
				return "character"
			}
			else {
				return "character(\(n))"
			}
		case .text:
			return "text"
		case .bytea:
			return "bytea"
		case .timestampWithoutTimeZone(let p):
			if let precision = p {
				let clipped = max(0, min(precision, 6));
				return "timestamp(\(clipped)) without time zone"
			}
			return "timestamp without timezone"
		case .timestampWithTimeZone(let p):
			if let precision = p {
				let clipped = max(0, min(precision, 6));
				return "timestamp(\(clipped)) with time zone"
			}
			return "timestamp with time zone"
		case .timeWithoutTimeZone(let p):
			if let precision = p {
				let clipped = max(0, min(precision, 6));
				return "time(\(clipped)) without time zone"
			}
			return "time without timezone"
		case .timeWithTimeZone(let p):
			if let precision = p {
				let clipped = max(0, min(precision, 6));
				return "time(\(clipped)) with time zone"
			}
			return "time with time zone"
		case .date:
			return "date"
		case .interval(let field, let p):
			if let precision = p {
				let clipped = max(0, min(precision, 6));
				return "interval \(field.rawValue)(\(clipped))"
			}
			return "interval \(field.rawValue)"
		case .point:
			return "point"
		case .line:
			return "line"
		case .lineSegment:
			return "lseg"
		case .box:
			return "box"
		case .path:
			return "path"
		case .polygon:
			return "polygon"
		case .circle:
			return "circle"
		case .cidr:
			return "cidr"
		case .inet:
			return "inet"
		case .macAddress:
			return "macaddr"
		case .bit(let n):
			if n <= 1 {
				return "bit(1)"
			}
			else {
				return "bit(\(n))"
			}
		case .bitVarying(let n):
			if n == 0 {
				return "bit varying"
			}
			else {
				return "bit varying(\(n))"
			}
		case .textSearchVector:
			return "tsvector"
		case .textSearchQuery:
			return "tsquery"
		case .uuid:
			return "uuid"
		case .xml:
			return "xml"
		case .json:
			return "json"
		case .jsonb:
			return "jsonb"
		case .array(let type, let length):
			if let len = length {
				if len > 0 {
					return type.dbString() + "[\(len)]"
				}
			}
			return type.dbString() + "[]"
		}
	}
}

public func ==(lhs: PGType, rhs: PGType) -> Bool {
	switch (lhs, rhs) {
	case (.boolean, .boolean): return true
	case (.smallInt, .smallInt): return true
	case (.integer, .integer): return true
	case (.bigInt, .bigInt): return true
	case (.real, .real): return true
	case (.doublePrecision, .doublePrecision): return true
	case (.smallSerial, .smallSerial): return true
	case (.serial, .serial): return true
	case (.bigSerial, .bigSerial): return true
	case (.money, .money): return true
	case (.numeric(let s, let t), .numeric(let u, let v)): return (s == u) && (t == v)
	case (.varchar(let s), .varchar(let t)): return s == t
	case (.character(let s), .character(let t)): return s == t
	case (.text, .text): return true
	case (.bytea, .bytea): return true
	case (.timestampWithoutTimeZone(let u), .timestampWithoutTimeZone(let v)): return u == v
	case (.timestampWithTimeZone(let u), .timestampWithTimeZone(let v)): return u == v
	case (.timeWithoutTimeZone(let u), .timeWithoutTimeZone(let v)): return u == v
	case (.timeWithTimeZone(let u), .timeWithTimeZone(let v)): return u == v
	case (.date, .date): return true
	case (.interval(let s, let t), .interval(let u, let v)): return (s == u) && (t == v)
	case (.point, .point): return true
	case (.line, .line): return true
	case (.lineSegment, .lineSegment): return true
	case (.box, .box): return true
	case (.path, .path): return true
	case (.polygon, .polygon): return true
	case (.circle, .circle): return true
	case (.cidr, .cidr): return true
	case (.inet, .inet): return true
	case (.macAddress, .macAddress): return true
	case (.bit(let s), .bit(let t)): return s == t
	case (.bitVarying(let s), .bitVarying(let t)): return s == t
	case (.textSearchVector, .textSearchVector): return true
	case (.textSearchQuery, .textSearchQuery): return true
	case (.uuid, .uuid): return true
	case (.xml, .xml): return true
	case (.json, .json): return true
	case (.jsonb, .jsonb): return true
	case (.array(let s, let t), .array(let u, let v)): return (s == u) && (t == v)

	case (.text, .varchar(let s)): return s == 0
	case (.varchar(let s), .text): return s == 0

	default: return false
	}
}
