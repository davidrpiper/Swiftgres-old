//
// PGDatabaseManager.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

import CLibpq

/// The protocol to implement to be a data model type.
/// Each implementer of PGDataModel (and their subclasses) should be comprised of
/// PG*Key*<T> fields that will be persisted to a connected database.
///
/// Swiftgres provides PGModel as a base data model types so you won't need to
/// implement this protocol directly unless you want your own data model base class.
public protocol PGDataModel {

	/// Called once by a PGDatabaseManager (sub)class to identify itself to the model.
	static func associateManager(_ manager: PGDatabaseManager)

	/// Return the name of the table to be used for the data model of this class.
	static func tableName() -> String

	/// Erases all rows in the table for this data model (specified by tableName()) that
	/// match the supplied filter.
	static func erase(_ filter: String) -> PGEraseResult

	/// Fetches all rows in the table for this data model (specified by tableName()) that
	/// match the supplied filter
	static func fetch(_ filter: String) -> PGFetchResult

	/// Save the current object into a row of this class's data model table.
	func save() -> PGSaveResult
}

/// A parent class for all database managers. Note that additional utility
/// methods are defined in PGUtils.swift. The most common way to use this
/// class is to create a subclass that only overrides the dataModel() method.
open class PGDatabaseManager {

	/// The database connection object
	internal var databaseConnection: OpaquePointer?

	/// The schema to connect to. A value of nil implies "public".
	internal var schema: String?

	// The prepared statements used by this class
	private typealias PreparedStatement = (name: String, statement: String, nParams: Int32)
	private let preparedStatements: [PreparedStatement] = [
		(name: "TABLE_INFORMATION", statement: "SELECT table_name FROM information_schema.tables WHERE table_schema = $1 AND table_type = 'BASE TABLE'", nParams: 1),
		(name: "COLUMN_INFORMATION", statement: "SELECT column_name,data_type FROM information_schema.columns WHERE table_name = $1 AND table_schema = $2;", nParams: 2)
	]

	/// Designated init method
	public init() { }

	/// Returns the data model classes to persist in the connected database.
	/// Subclasses should override this method to return all their required
	/// PGModel classes.
	///
	/// Note you can create many data model classes and structs, but only
	/// those returned here will be recognised by Swiftgres. This provides a
	/// convenient on/off switch for any model class(es) that is invovled in a
	/// database migration.
	///
	/// Additionally, substituting data models here with the same table names
	/// can be an easy way of testing alternative implementations of the same
	/// model.
	open func dataModel() -> [PGDataModel.Type] {
		// XXX: Hack until the Swift compiler stops shitting itself in the
		// DatabaseManagerTests.
		//return []
		return [PGModel.self]
	}

	/// Attempts a connection to a database described by the parameters array.
	/// Each type of PGConnectionParameter should appear at most once.
	/// If the connection is successful, the specified data model is validated
	/// against the existing database structure. Any database connection opened
	/// is only left open if this method returns .successful. Otherwise, the
	/// connection is closed on the caller's behalf.
	///
	/// Swiftgres allows communication with TLS/SSL but explicitly does NOT
	/// initialise the libSSL and libcrypto libraries. If you wish to connect
	/// to a database over TLS/SSL (see PGConnectionParameter), you must have
	/// already initialized the appropriate libraries.
	final public func connect(_ parameters: [PGConnectionParameter]) -> PGConnectionResult {

		// We require 64-bit Ints
		if MemoryLayout<Int>.size != 8 {
			return .not64Bit
		}

		// No DB required
		let model = self.dataModel()
		if model.count == 0 {
			return .unnecessary
		}

		// Validate parameters were specified at most once
		let parameterSet = Set<PGConnectionParameter>(parameters)
		if parameters.count != parameterSet.count {
			let error = "Swiftgres failed to connect to the database as a connection parameter was specified multiple times."
			return .failed(error)
		}

		// Generate connection parameters string
		var connectionInfo: String = ""
		for param in parameters {
			let key = param.keyString()
			let value = param.valueString()
			connectionInfo.append("\(key)='\(value)'")
		}

		// Explicitly do not initialise SSL/crypto libraries
		PQinitOpenSSL(0, 0)

		// Start the connection
		let connection = PQconnectdb(connectionInfo)
		let status = PQstatus(connection)
		switch status {
		case CONNECTION_OK:
			self.databaseConnection = connection
		case CONNECTION_BAD:
			let message = PQerrorMessage(connection)
			if let message = message {
				let string = String(cString: message)
				return .failed(string)
			}
			fallthrough
		default:
			let error = "Swiftgres failed to connect to the database for an unknown reason."
			return .failed(error)
		}

		// Prepare known statements
		for s in preparedStatements {
			let result = PQprepare(databaseConnection,
			                       s.name.data(using: String.Encoding.utf8)!.withUnsafeBytes{ $0 },
			                       s.statement.data(using: String.Encoding.utf8)!.withUnsafeBytes{ $0 },
			                       s.nParams,
			                       nil)
			
			let status = PQresultStatus(result)
			if status != PGRES_COMMAND_OK {
				let message = PQresultErrorMessage(result)
				let prefix = "Swiftgres failed to prepare statement `\(s.statement)`. Reason: "
				let error = (message != nil) ? String(cString: message!) : "Unknown"
				PQclear(result)
				PQfinish(databaseConnection)
				return .failed(prefix + error)
			}
			PQclear(result)
		}

		// Run validation
		let validationResult = validate()
		if case .failed(_) = validationResult {
			PQfinish(databaseConnection)
			return .failedValidation(validationResult)
		}

		// Identify self to model classes. Each model class could be a different
		// implementation of PGDataModel.
		for clazz in model {
			clazz.associateManager(self)
		}

		return .successful(validationResult)
	}

	/// Disconnects from the database. No-op if no database connection exists.
	final public func disconnect() {
		if databaseConnection != nil {
			PQfinish(databaseConnection!)
		}
	}

	/// Validates that the database to which we are currently connected has
	/// AT LEAST the requried database tables and (correctly typed) columns
	/// to correctly interact with the specified data model.
	final public func validate() -> PGValidationResult {
		return .successful([:])

		/*
		// Check all the required tables.

		// For the tables that do exist, check what columns are correct.
		let arrayOfExistingTableNames: [String] = []
		for tableName in arrayOfExistingTableNames {
			// (Should return types without params)
			//let query = "SELECT column_name,data_type FROM information_schema.columns WHERE table_name='\(tableName)' AND table_schema='\(schemaName)'"
		}

		return .failed([:])
		*/
	}

	/// Returns an SQL document that, when executed on an empty Postgres
	/// database (or a database with no other conflicting tables), will
	/// create and setup the tables and associated metadata required for
	/// persisting the specified data model in the database.
	final public func generateMigrationsForEmptyDatabase() -> String {
		return ""
	}
}

private protocol PGUtilityMethods { }

/// The precondition to all methods in this extension is that the database manager has
/// successfully connected to the database.
extension PGDatabaseManager : PGUtilityMethods {

	/*
	/// Set up the database's schema search_path. The 'public' schema will automatically
	/// be added to the end of the search_path.
	final public func setSchemaSearchPath(schemas: [String]) -> Bool {

		// Apparently this statement cannot be a prepared statement.
		let path = (schemas.count < 1) ? "public" : schemas.joined(separator: ",") + ",public"
		let query = "SET search_path TO \(path);"

		let result = PQexec(self.databaseConnection, query)

		var opt: PQprintOpt = PQprintOpt()

		PQprint(__stderrp, result, &opt)

		let status = PQresultStatus(result)
		if status == PGRES_COMMAND_OK {
			PQclear(result)
			return true
		}
		PQclear(result)
		return false

		/*
		let schemaString = schemas.joined(separator: ",")
		let searchPath = "\(schemaString),public"
		let searchPathRaw: UnsafePointer<Int8>? = searchPath.data(using: String.Encoding.utf8)!.withUnsafeBytes{ $0 }

		let result = PQexecPrepared(self.databaseConnection,
		                            "SCHEMA_SEARCH_PATH",
		                            1,
		                            [searchPathRaw],
		                            nil,
		                            nil,
		                            0)

		let status = PQresultStatus(result)
		if status == PGRES_COMMAND_OK {
			PQclear(result)
			return true
		}
		PQclear(result)
		return false
		*/
	}
	*/
	
}

