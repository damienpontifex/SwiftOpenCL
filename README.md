# SwiftOpenCL

A swift wrapper around OpenCL inspired the C++ object wrapper.

Interfacing with C libraries from Swift is a pain. Alongside this, the OpenCL library is quite verbose to setup a working environment. This is the start of a Swift wrapper around the OpenCL API.

## Using Swift Package Manager

Sample Package.swift file

```swift
import PackageDescription

let package = Package(
	name: "<Project Name>",
    dependencies: [
        .Package(url: "https://github.com/damienpontifex/SwiftOpenCL.git", majorVersion: 0)
    ]
)
```

Sample main.swift file

```swift
import SwiftOpenCL
#if os(Linux)
//TODO: Add OpenCL module import for Linux
#else
import OpenCL
#endif

let platforms = Platform.allPlatforms()

for platform in platforms
{
    guard let extensions = platform.getInfo(CL_PLATFORM_EXTENSIONS) else {
        continue
    }
    
    print(extensions)
}
```

## Sample usage

A simple vector addition kernel.

```swift
let vecAddFilePath = NSBundle.mainBundle().pathForResource("vec_add", ofType: "cl")
let vecAdd = NSString(contentsOfFile: vecAddFilePath!, encoding: NSUTF8StringEncoding, error: nil) as! String

let platforms = Platform.allPlatforms()
let devices = platforms.first!.getDevices(CL_DEVICE_TYPE_CPU)

let context = Context(devices: devices)
let commandQueue = CommandQueue(context: context, device: devices.first!)
let program = Program(context: context, programSource: vecAdd)
program?.build(devices.first!)
let kernel = Kernel(program: program!, kernelName: "vec_add")!

let elements = 2048

var a = map(0..<elements) {
	cl_int($0)
}
var b = a

let aBuffer = Buffer(context: context, readOnlyData: a)
let bBuffer = Buffer(context: context, readOnlyData: b)
let cBuffer = Buffer<cl_int>(context: context, count: elements)

var status = kernel.setArg(0, buffer: aBuffer)
status |= kernel.setArg(1, buffer: bBuffer)
status |= kernel.setArg(2, buffer: cBuffer)

if status != CL_SUCCESS {
	print("Set kernel arg failed \(status)")
}

var workDim: cl_uint = 1
var globalWorkSize: size_t = elements
var globalWorkOffset: size_t = 0
clEnqueueNDRangeKernel(
	commandQueue.queue,
	kernel.kernel,
	workDim,
	&globalWorkOffset,
	&globalWorkSize,
	nil,
	0,
	nil,
	nil)

var c = cBuffer.enqueueRead(commandQueue)

print(c)
```
