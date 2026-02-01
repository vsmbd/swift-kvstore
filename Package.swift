// swift-tools-version: 6.2

import PackageDescription

let package = Package(
	name: "KVStore",
	products: [
		.library(
			name: "KVStore",
			targets: ["KVStore"]
		)
	],
	dependencies: [
		.package(
			url: "https://github.com/vsmbd/swift-core.git",
			branch: "main"
		)
	],
	targets: [
		.target(
			name: "KVStore",
			dependencies: [
				.product(
					name: "SwiftCore",
					package: "swift-core"
				)
			],
			path: "Sources/KVStore"
		),
		.testTarget(
			name: "KVStoreTests",
			dependencies: [
				"KVStore",
				.product(name: "SwiftCore", package: "swift-core")
			],
			path: "Tests/KVStoreTests"
		)
	]
)
