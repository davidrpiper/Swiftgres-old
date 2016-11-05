//
// PGModel.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

import CLibpq

/// A parent class for types that can be represented in a database table.
/// All PGModelSerial classes are given a Primary Key named 'id'.
open class PGModel: PGDataModel {

	/// The connection object handed over by the database manager
	private static var connection: OpaquePointer?

	/// The id of the object in the database. Will be nil if the object has been
	/// constructed but not yet saved to the database.
	private(set) var id: PGPrimaryKey<PGBigSerial>?

	public static func associateManager(_ manager: PGDatabaseManager) {
		// We assume the connection exists at this point as a safety
		// mechanism. If it doesn't, there are bigger problems and this
		// will crash before any of them can be encountered.
		connection = manager.databaseConnection
	}

	/// If this is not overridden by subclasses, the lowercased name of the class itself
	/// will be used as the table name.
	open class func tableName() -> String {
		return String(describing: type(of: self)).lowercased()
	}

	public static func erase(_ filter: String) -> PGEraseResult {
		//type(of: self)
		return .successful(1)
	}

	public static func fetch(_ filter: String) -> PGFetchResult {
		//type(of: self).init(...)
		return .successful([])
	}

	// We do this redirect so we can test the save method more effectively.
	final public func save() -> PGSaveResult {
		return self._save().0
	}

	// If the connection object is nil, this method will do a dry run of
	// the save operation. The final String? is the prepared statement if
	// it was constructed.
	// TODO: don't rewrite the entire row if only a few values have changed.
	// Keep track of the "dirty values" maybe inside the PGKeyType class on set.
	final internal func _save() -> (PGSaveResult, [(columnName: String, value: String)], (preparedStatementName: String, preparedStatement: String, nParams: Int32)?) {

		// The column names and values to insert
		var insertions: [(columnName: String, value: String)] = []

		// Get all PGKeyType subclasses in the entire class heirarchy and extract
		// the values needed to write the data to the database.
		var mirrorOpt: Mirror? = Mirror(reflecting: self)
		while let mirror = mirrorOpt {
			let fields = mirror.children
			for field in fields {
				if let key = field.value as? PGKeyType {
					let dbValue: String
					if let value = key.get() {
						dbValue = value.databaseValue()
					}
					else {
						dbValue = "null"
					}
					guard let columnName = field.label else {
						let type = String(describing: type(of:self))
						let error = "Field with value \(dbValue) has no name. \(type) was not saved."
						return (.failed(error), insertions, nil)
					}
					// Always exclude id as we never explicitly save it.
					if columnName != "id" {
						insertions.append((columnName, dbValue))
					}
				}
			}
			mirrorOpt = mirror.superclassMirror
		}

		// Create the prepared statement name
		let operationString = (self.id != nil) ? "UPDATE" : "INSERT"
		let colNames = insertions.map{ "_" + $0.columnName }
		let preparedStatementName = colNames.reduce(operationString + "_" + type(of: self).tableName(), +)

		// Identify number of prepared parameters. The one additional parameter
		// is for the WHERE id = $n clause.
		let nParams: Int32 = (operationString == "UPDATE") ? Int32(insertions.count) + 1 : Int32(insertions.count)

		// Check if the prepared statement already exists
		let descriptionResult: OpaquePointer?
		let descriptionStatus: ExecStatusType
		if let conn = PGModel.connection {
			descriptionResult = PQdescribePrepared(conn, preparedStatementName.withCString { $0 })
			descriptionStatus = PQresultStatus(descriptionResult)
			PQclear(descriptionResult)
		}
		else {
			// No-op
			descriptionStatus = PGRES_NONFATAL_ERROR
		}

		// If it doesn't already exist, create the prepared statement
		var preparedStatement: String = ""
		if descriptionStatus != PGRES_COMMAND_OK {

			// TODO: Change this to a more functional style
			if self.id != nil {
				preparedStatement = "UPDATE " + type(of: self).tableName() + " SET "
				var i: Int32 = 1
				for insertion in insertions {
					preparedStatement += insertion.columnName + " = $\(i), "
					i += 1
				}
				// Remove last space and comma
				preparedStatement.remove(at: preparedStatement.index(before: preparedStatement.endIndex))
				preparedStatement.remove(at: preparedStatement.index(before: preparedStatement.endIndex))
				preparedStatement += " WHERE id = $\(i);"
			}
			else {
				preparedStatement = "INSERT INTO " + type(of: self).tableName() + " ("
				var i: Int32 = 1
				var parameterString = ""
				for insertion in insertions {
					preparedStatement += insertion.columnName + ", "
					parameterString += "$\(i), "
					i += 1
				}
				// Remove last space and comma
				preparedStatement.remove(at: preparedStatement.index(before: preparedStatement.endIndex))
				preparedStatement.remove(at: preparedStatement.index(before: preparedStatement.endIndex))
				parameterString.remove(at: parameterString.index(before: parameterString.endIndex))
				parameterString.remove(at: parameterString.index(before: parameterString.endIndex))
				preparedStatement += ") VALUES (" + parameterString + ") RETURNING id;"
			}

			// Send the prepare request
			if let conn = PGModel.connection {
				let prepareResult = PQprepare(conn, preparedStatementName, preparedStatement, nParams, nil)
				let status = PQresultStatus(prepareResult)
				if status != PGRES_COMMAND_OK {
					let message = PQresultErrorMessage(prepareResult)
					let prefix = "Swiftgres failed to prepare statement `\(preparedStatement)`. Reason: "
					let error = (message != nil) ? String(cString: message!) : "Unknown"
					PQclear(prepareResult)
					return (.failed(prefix + error), insertions, (preparedStatementName, preparedStatement, nParams))
				}
				PQclear(prepareResult)
			}
		}

		// Get the database literals of the raw values to be inserted
		let rawValues: UnsafePointer<UnsafePointer<Int8>?> = UnsafePointer(insertions.map { UnsafePointer<Int8>($0.value.withCString { $0 }) })

		// Execute the prepared statement
		if let conn = PGModel.connection {
			let execResult = PQexecPrepared(conn, preparedStatementName, nParams, rawValues, nil, nil, 0)
			let status = PQresultStatus(execResult)
			if status != PGRES_COMMAND_OK {
				let message = PQresultErrorMessage(execResult)
				let prefix = "Swiftgres failed to execute prepared statement `\(preparedStatementName)`. Reason: "
				let error = (message != nil) ? String(cString: message!) : "Unknown"
				PQclear(execResult)
				return (.failed(prefix + error), insertions, (preparedStatementName, preparedStatement, nParams))
			}

			// Save the returned ID back into the object
			let idValue = PQgetvalue(execResult, 0, 0)!
			let idString = String(utf8String: UnsafePointer<CChar>(idValue))!
			let idInt = Int(idString)!
			self.id = PGPrimaryKey(PGBigSerial(value: idInt))
			PQclear(execResult)
		}
		else {
			// For a dry run we just set id to 1
			self.id = PGPrimaryKey(1)
		}

		// If we got to here, everything went fine (real or dry run).
		return (.successful, insertions, (preparedStatementName, preparedStatement, nParams))
	}

}
