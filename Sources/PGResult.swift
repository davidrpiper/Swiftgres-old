//
// PGResult.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

/// Encapsulates the result of a database save operation.
/// Testing equality DOES NOT consider associated values for .failed as
/// they are meant to be descriptive only, rather than deterministic.
public enum PGSaveResult: Equatable {
	/// Indicates the calling object was successfully saved (persisted)
	/// to the connected database.
	case successful

	/// Indicates there was an error saving the caller to the database.
	/// If this result is returned, the database will be left in the
	/// same state as it was before the save operation was requested.
	/// The associated String describes the reason for the failure.
	case failed(String)
}

/// Encapsulates the result of a database fetch operation.
/// Testing equality DOES NOT consider associated values for .failed.
/// Testing equality ONLY considers the count of the returned PGDataModel
/// array for the .successful case, not the data models themselves.
public enum PGFetchResult: Equatable {
	/// Indicates a successful fetch of models from the database. The
	/// associated array of PGDataModels are the objects returned (the
	/// array may be empty).
	case successful([PGDataModel])

	/// Indicates there was an error fetching models from the database.
	/// The associated String describes the reason for the failure.
	case failed(String)
}

/// Encapsulates the result of a database erase operation.
/// Testing equality ONLY considers associated values for .successful.
public enum PGEraseResult: Equatable {
	/// Indicate a successful erase operation. The associated Int is the
	/// number of database entries that were erased.
	case successful(Int)

	/// Indicates there was an error erasing models from the database.
	/// If this result is returned, it guranatees the database is in the
	/// same state as it was before the save operation was requested (no
	/// data was erased).
	/// The associated String describes the reason for the failure.
	case failed(String)
}

/// Encapsulates the result of a database validation.
/// Testing equality DOES NOT consider associated values.
public enum PGValidationResult: Equatable {
	/// Indicates a successful database validation.
	/// A successful validation means the connected database has AT LEAST
	/// required tables with AT LEAST the required columns specified by
	/// the models returned by the PGManager's models() method.
	///
	/// The returned dictionary indicates the existing or additional tables
	/// (the keys) that have additonal columns (the values) on top of what
	/// is required by the data model. This information will prove useful
	/// when performing database migrations for a live service.
	case successful([String:[(String, PGType)]])

	/// Indicates a failed database validation.
	/// A failed validation means the connected database does not have the
	/// tables and/or columns required by the database model.
	/// It is recommended (though not required) that that an application
	/// should terminate immediately if the database validation fails (see
	/// the PGManager class).
	///
	/// The returned dictionary indicates the missing tables (the keys) and
	/// columns therein (the values) that are missing from the database.
	case failed([String:[(String, PGType)]])
}

/// Encapsulates the result of a database connection attempt.
/// Testing equality DOES NOT consider associated values.
public enum PGConnectionResult: Equatable {
	/// Indicates Swiftgres succesfully managed to connect to the specified
	/// database, accounting for all supplied connection parameters.
	/// Returns a successful PGValidationResult.
	case successful(PGValidationResult)

	/// Indicates Swiftgres failed to connect to the specified database.
	/// The associated String describes the reason for the failure.
	case failed(String)

	/// Indicates Swiftgres succesfully connected to the database but the
	/// validation against the supplied data model failed. Migrations will
	/// need to be run on the database to align it with the supplied model.
	case failedValidation(PGValidationResult)

	/// Indicates Swiftgres did not even attempt a database connection as
	/// no data model has been specified, and a database is therefore not
	/// required.
	case unnecessary

	/// Indicates Swiftgres did not attempt to make a database connection as
	/// the native Int type is not 64 bits (a Swiftgres requriement).
	case not64Bit
}

public func ==(lhs: PGSaveResult, rhs: PGSaveResult) -> Bool {
	switch (lhs, rhs) {
	case (.successful, .successful): return true
	case (.failed(_), .failed(_)): return true
	default: return false
	}
}

public func ==(lhs: PGFetchResult, rhs: PGFetchResult) -> Bool {
	switch (lhs, rhs) {
	case (.successful(let s), .successful(let t)): return s.count == t.count
	case (.failed(_), .failed(_)): return true
	default: return false
	}
}

public func ==(lhs: PGEraseResult, rhs: PGEraseResult) -> Bool {
	switch (lhs, rhs) {
	case (.successful(let s), .successful(let t)): return s == t
	case (.failed(_), .failed(_)): return true
	default: return false
	}
}

public func ==(lhs: PGValidationResult, rhs: PGValidationResult) -> Bool {
	switch (lhs, rhs) {
	case (.successful(_), .successful(_)): return true
	case (.failed(_), .failed(_)): return true
	default: return false
	}
}

public func ==(lhs: PGConnectionResult, rhs: PGConnectionResult) -> Bool {
	switch (lhs, rhs) {
	case (.successful(_), .successful(_)): return true
	case (.failed(_), .failed(_)): return true
	case (.failedValidation(_), .failedValidation(_)): return true
	case (.unnecessary, .unnecessary): return true
	case (.not64Bit, .not64Bit): return true
	default: return false
	}
}
