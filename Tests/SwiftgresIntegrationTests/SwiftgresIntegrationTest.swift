//
// SwiftgresIntegrationTest.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

import XCTest
@testable import Swiftgres

// MARK: - Environment requirements

#if os(Linux)
	import GlibC
#else
	import Foundation
#endif

#if os(Linux)
let dockerExecutable = "/usr/local/bin/docker"
	fileprivate func shell(_ launchPath: String, args: [String]) -> (Int32, String?) {
		return (0, nil)
	}
#else
let dockerExecutable = "/usr/local/bin/docker"
	fileprivate func shell(_ launchPath: String, args: [String]) -> (Int32, String?) {
		let task = Process()
		task.launchPath = launchPath
		task.arguments = args

		let pipe = Pipe()
		task.standardOutput = pipe
		task.launch()

		let data = pipe.fileHandleForReading.readDataToEndOfFile()
		let output: String? = String(data: data, encoding: String.Encoding.utf8)

		task.waitUntilExit()
		return (task.terminationStatus, output)
	}
#endif

// MARK: - SwiftgresIntegrationTest

// Self-contained integration tests using proper data models and PGDatabaseManager subclasses.
class SwiftgresIntegrationTest: XCTestCase {

	// The list of (Docker) Postgres versions to run integration tests against.
	static let postgresVersions = ["9"]

	// The required connection parameters
	static let dbParams: [PGConnectionParameter] = [
		.user("test_user"),
		.password("test_password"),
		.host("localhost"),
		.dbName("test_db"),
		.port(5432)
	]

	// The database manager
	var connection: (manager: PGDatabaseManager, result: PGConnectionResult)?

	override class func setUp() {
		super.setUp()
		pullPostgresImages()
		spinupAndWaitForPostgresContainers()
	}

	override class func tearDown() {
		super.tearDown()
		terminatePostgresContainers()
	}

	// Start up our DB connection before every test.
	override func setUp() {
		let manager: PGDatabaseManager = PGDatabaseManager()
		let params: [PGConnectionParameter] = SwiftgresIntegrationTest.dbParams
		self.connection = (manager, manager.connect(params))
	}

	// Close our DB connection after every test.
	override func tearDown() {
		if let conn = self.connection {
			conn.manager.disconnect()
		}
	}

	// Pull all Docker images before we start the tests
	private class func pullPostgresImages() {
		for version in postgresVersions {
			let image = "postgres:\(version)"
			print("Pulling \(image) from Docker Hub...")
			let ret = shell(dockerExecutable, args: ["pull", "\(image)"])
			if ret.0 != 0 {
				XCTFail("Cannot pull \(image) from Docker Hub.\n\(ret.1)")
			}
		}
	}

	// Spin up the containers
	private class func spinupAndWaitForPostgresContainers(waitTimePerContainer: UInt32 = 30) {
		for version in SwiftgresIntegrationTest.postgresVersions {
			let image = "postgres:\(version)"
			print("Spinning up \(image) on Docker...")
			DispatchQueue.global(qos: .userInitiated).async {
				let args = ["run", "--name", "swifgres-pg-\(version)", "-p", "5432:5432",
				            "-e", "POSTGRES_USER=test_user", "-e", "POSTGRES_PASSWORD=test_password", "-e", "POSTGRES_DB=test_db",
				            "-d", "\(image)"]
				_ = shell(dockerExecutable, args: args)
			}
		}
		print("Waiting \(waitTimePerContainer * UInt32(SwiftgresIntegrationTest.postgresVersions.count)) seconds for Postgres container(s) to start...")
		sleep(waitTimePerContainer * UInt32(SwiftgresIntegrationTest.postgresVersions.count))
	}

	// Terminate and remove all containers spun up for this test
	private class func terminatePostgresContainers() {
		print("Terminating and removing all Postgres containers...")
		for version in SwiftgresIntegrationTest.postgresVersions {
			_ = shell(dockerExecutable, args: ["rm", "-f", "swifgres-pg-\(version)"])
		}
	}
}
