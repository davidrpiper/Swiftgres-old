//
// PGKey.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

/// These classes are all just thin wrappers of the raw database values;
/// it is the type information that allows Swiftgres to store the values
/// correctly in the database.
public class PGKeyType {
	internal var value: PGTypeConvertible?
	internal var allowsNull : Bool

	internal init(allowsNull: Bool) {
		self.allowsNull = allowsNull
	}
	final public func get() -> PGTypeConvertible? {
		return value
	}
}

/// An object that will be stored as a value in a database table column.
/// A value of nil represents a null database value.
public class PGKey<T: PGTypeConvertible>: PGKeyType {
	public init(_ value: T?) {
		super.init(allowsNull: true)
		self.value = value
	}
}

/// An object that will be saved as a primary key value in the containing
/// object's database table. PGPrimaryKeys can be specified as optional if
/// they are not assigned until the value is stored in the database.
/// Note: you shouldn't need to use this class unless you're writing your
/// own base data model class.
public class PGPrimaryKey<T: PGTypeConvertible>: PGKeyType {
	public init(_ value: T) {
		super.init(allowsNull: false)
		self.value = value
	}
}

/// TODO: Foreign keys
/// An object that will be saved as a primary key value in the containing
/// object's database table (referencing the table specified by T's class).
/// A value of nil represents a null database value.
/*
public class PGForeignKey<T: PGDataModel>: PGKeyType {
	var value: T?
	final public func get() -> T? {
		return value
	}
	public init(_ value: T) {
		// TODO
		self.value = value
	}
}
*/

/// Keys with various column restricitons
public class PGKeyUnique<T: PGTypeConvertible>: PGKey<T> { }
public class PGKeyUniqueNotNull<T: PGTypeConvertible>: PGPrimaryKey<T> { }
public class PGKeyNotNull<T: PGTypeConvertible>: PGPrimaryKey<T> { }

/// Foreign keys of various ON DELETE flavours
//public class PGForeignKeyRestrict<T: PGDataModel>: PGForeignKey<T> { }
//public class PGForeignKeyCascade<T: PGDataModel>: PGForeignKey<T> { }
//public class PGForeignKeySetNull<T: PGDataModel>: PGForeignKey<T> { }
//public class PGForeignKeySetDefault<T: PGDataModel>: PGForeignKey<T> { }
