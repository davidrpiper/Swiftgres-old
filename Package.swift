//
// Package.swift
// Swifgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

import PackageDescription

#if os(OSX)
let libPq = Package.Dependency.Package(url: "https://github.com/cswiftmodules/CLibpq-local.git", majorVersion: 1)
#else
let libPq = Package.Dependency.Package(url: "https://github.com/cswiftmodules/CLibpq.git", majorVersion: 1)
#endif

let package = Package(
	name: "Swiftgres",
	dependencies: [
		libPq
	]
)
