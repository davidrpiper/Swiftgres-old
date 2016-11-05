//
// PGType-Bool.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

extension Bool : PGTypeConvertible {
	public static func databaseType() -> PGType {
		return .boolean
	}
	public func databaseValue() -> String {
		return (self) ? "TRUE" : "FALSE"
	}
}
