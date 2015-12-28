import PackageDescription

let package = Package(
	name: "SwiftOpenCL"
)

// From https://github.com/apple/swift-package-manager/blob/master/Documentation/Package.swift.md#customizing-builds
// Test how to link against OpenCL in Linux with this...
#if os(Linux)
let target = Target(name: "LinuxSources/foo")
package.targets.append(target)
#endif