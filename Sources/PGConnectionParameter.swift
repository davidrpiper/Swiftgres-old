//
// PGConnectionParameter.swift
// Swiftgres
//
// Copyright © 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

/// Parameters that can be specified when attempting a connection to a database.
/// See the official libpq documentation for detailed documentation.
public enum PGConnectionParameter: Hashable {

	public enum PGSSLMode: String {
		case Disable = "disable"
		case Allow = "allow"
		case Prefer = "prefer"
		case Require = "require"
		case VerifyCA = "verify-ca"
		case VerifyFull = "verify-full"
	}

	case host(String)
	case hostAddr(String)
	case port(UInt16)
	case dbName(String)
	case user(String)
	case password(String)
	case connectTimeout(UInt)
	case clientEncoding(String)
	case options(String)

	case applicationName(String)
	case fallbackApplicationName(String)

	case keepalives(Bool)
	case keepalivesIdle(UInt)
	case keepalivesInterval(UInt)
	case keepalivesCount(UInt)

	case sslMode(PGSSLMode)
	case sslCompression(Bool)
	case sslCertificate(String)
	case sslKey(String)
	case sslRootCert(String)
	case sslCrl(String)

	case requirePeer(String)
	case krbsrvName(String)
	case gssLib(String)
	case service(String)

	// Added by Swiftgres: set schema search paths
	//case searchPaths([String])

	func keyString() -> String {
		switch self {
		case .host(_):
			return "host"
		case .hostAddr(_):
			return "hostaddr"
		case .port(_):
			return "port"
		case .dbName(_):
			return "dbname"
		case .user(_):
			return "user"
		case .password(_):
			return "password"
		case .connectTimeout(_):
			return "connect_timeout"
		case .clientEncoding(_):
			return "client_encoding"
		case .options(_):
			return "options"
		case .applicationName(_):
			return "application_name"
		case .fallbackApplicationName(_):
			return "fallback_application_name"
		case .keepalives(_):
			return "keepalives"
		case .keepalivesIdle(_):
			return "keepalives_idle"
		case .keepalivesInterval(_):
			return "keepalives_interval"
		case .keepalivesCount(_):
			return "keepalives_count"
		case .sslMode(_):
			return "sslmode"
		case .sslCompression(_):
			return "sslcompression"
		case .sslCertificate(_):
			return "sslcert"
		case .sslKey(_):
			return "sslkey"
		case .sslRootCert(_):
			return "sslrootcert"
		case .sslCrl(_):
			return "sslcrl"
		case .requirePeer(_):
			return "requirepeer"
		case .krbsrvName(_):
			return "krbsrvname"
		case .gssLib(_):
			return "gsslib"
		case .service(_):
			return "service"
		}
	}

	func valueString() -> String {
		switch self {
		case .host(let value):
			return value
		case .hostAddr(let value):
			return value
		case .port(let value):
			return String(value)
		case .dbName(let value):
			return value
		case .user(let value):
			return value
		case .password(let value):
			return value
		case .connectTimeout(let value):
			return String(value)
		case .clientEncoding(let value):
			return value
		case .options(let value):
			return value
		case .applicationName(let value):
			return value
		case .fallbackApplicationName(let value):
			return value
		case .keepalives(let value):
			return value ? "1" : "0"
		case .keepalivesIdle(let value):
			return String(value)
		case .keepalivesInterval(let value):
			return String(value)
		case .keepalivesCount(let value):
			return String(value)
		case .sslMode(let value):
			return value.rawValue
		case .sslCompression(let value):
			return value ? "1" : "0"
		case .sslCertificate(let value):
			return value
		case .sslKey(let value):
			return value
		case .sslRootCert(let value):
			return value
		case .sslCrl(let value):
			return value
		case .requirePeer(let value):
			return value
		case .krbsrvName(let value):
			return value
		case .gssLib(let value):
			return value
		case .service(let value):
			return value
		}
	}

	public var hashValue: Int {
		return self.keyString().hashValue
	}
}

public func ==(lhs: PGConnectionParameter, rhs: PGConnectionParameter) -> Bool {
	switch (lhs, rhs) {
	case (.host(_), .host(_)): return true
	case (.hostAddr(_), .hostAddr(_)): return true
	case (.port(_), .port(_)): return true
	case (.dbName(_), .dbName(_)): return true
	case (.user(_), .user(_)): return true
	case (.password(_), .password(_)): return true
	case (.connectTimeout(_), .connectTimeout(_)): return true
	case (.clientEncoding(_), .clientEncoding(_)): return true
	case (.options(_), .options(_)): return true
	case (.applicationName(_), .applicationName(_)): return true
	case (.fallbackApplicationName(_), .fallbackApplicationName(_)): return true
	case (.keepalives(_), .keepalives(_)): return true
	case (.keepalivesIdle(_), .keepalivesIdle(_)): return true
	case (.keepalivesInterval(_), .keepalivesInterval(_)): return true
	case (.keepalivesCount(_), .keepalivesCount(_)): return true
	case (.sslMode(_), .sslMode(_)): return true
	case (.sslCompression(_), .sslCompression(_)): return true
	case (.sslCertificate(_), .sslCertificate(_)): return true
	case (.sslKey(_), .sslKey(_)): return true
	case (.sslRootCert(_), .sslRootCert(_)): return true
	case (.sslCrl(_), .sslCrl(_)): return true
	case (.requirePeer(_), .requirePeer(_)): return true
	case (.krbsrvName(_), .krbsrvName(_)): return true
	case (.gssLib(_), .gssLib(_)): return true
	case (.service(_), .service(_)): return true
	default: return false
	}
}
