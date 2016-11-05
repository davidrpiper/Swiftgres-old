//
// PGType-Array.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

/// A wrapper class for a Postgres array of any type.
public class PGArray<T: PGTypeConvertible> : PGTypeConvertible {
	var array: [T]
	public init(_ array: [T]) {
		self.array = array
	}
	public static func databaseType() -> PGType {
		return .array(T.databaseType(), nil)
	}
	public func databaseValue() -> String {
		let elements = self.array.map{ $0.databaseValue() }

		// We only want safe elements for the basic non-Array type
		// XXX: Surely there is a more precise way to do that with Swift's type system?
		let safeElements = (String(describing: T.self).hasPrefix("PGArray")) ? elements : elements.map { "\"" + $0 + "\"" }

		let arrayElements = safeElements.joined(separator: ",")
		let array = "{" + arrayElements + "}"

		// Remove all inner ' marks. No-op for 1-dimensional arrays
		let recursiveArray = array.replacingOccurrences(of: "'", with: "")

		return "'" + recursiveArray + "'"
	}
}
