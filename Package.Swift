import PackageDescription

let package = Package(
	name: "SwiftOpenCL",
	targets: [
		Target(name: "SwiftOpenCL"),
		Target(name: "SimpleKernel", dependencies: [.Target(name: "SwiftOpenCL")])
	]
)
