//
// PGType-Strings.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

extension String : PGTypeConvertible {
	public static func databaseType() -> PGType {
		return .text
	}
	public func databaseValue() -> String {
		let escaped = self.replacingOccurrences(of: "'", with: "\'")
		return "'\(escaped)'"
	}
}
