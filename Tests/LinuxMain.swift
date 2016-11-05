//
//  LinuxMain.swift
//  Swiftgres
//
//  Created by David Piper on 1/10/2016.
//  Copyright © 2016 David Piper. All rights reserved.
//

import XCTest
import SwiftgresTests
import SwiftgresIntegrationTests

var tests: [XCTestCaseEntry] = []
tests += SwiftgresTests.allTests()
tests += SwiftgresIntegrationTests.allTests()
XCTMain(tests)

