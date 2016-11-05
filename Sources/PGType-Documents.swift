//
// PGType-Documents.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

/// A parent class for types such as PGXml and PGJson.
public class PGDocumentType {
	internal var content: String
	public init(fromString: String) {
		content = fromString
	}
	final public func databaseValue() -> String {
		return "'" + content + "'"
	}
	final public func getContent() -> String {
		return content
	}
}

/// A container type for XML objects. No validation is done on initialisation
/// so errors will not manifest until a database transaction is performed.
public class PGXml : PGDocumentType, PGTypeConvertible {
	public static func databaseType() -> PGType {
		return .xml
	}
}

/// A container type for JSON objects. No validation is done on initialisation
/// so errors will not manifest until a database transaction is performed.
public class PGJson : PGDocumentType, PGTypeConvertible {
	public static func databaseType() -> PGType {
		return .json
	}
}

/// Identical to PGJson but stored as binary JSON.
public class PGJsonb : PGDocumentType, PGTypeConvertible {
	public static func databaseType() -> PGType {
		return .jsonb
	}
}
