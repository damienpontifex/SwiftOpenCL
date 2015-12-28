//: Playground - noun: a place where people can play

import Foundation
import Accelerate
import OpenCL
import SwiftOpenCL
import XCPlayground

guard let vecAddFilePath = NSBundle.mainBundle().pathForResource("vec_add", ofType: "cl") else {
	XCPlaygroundPage.currentPage.finishExecution()
}

let platforms = Platform.allPlatforms()
print(platforms)

let devices = platforms.first!.getDevices(CL_DEVICE_TYPE_CPU)
print(devices)

if let gpuDevices = platforms.first?.getDevices(CL_DEVICE_TYPE_GPU) {
	print(gpuDevices)
}

let context = try Context(devices: devices)
try context.getInfo(cl_context_info(CL_CONTEXT_DEVICES), type: cl_device_id.self)

guard let firstDevice = devices.first else {
	XCPlaygroundPage.currentPage.finishExecution()
}

let commandQueue = try CommandQueue(context: context, device: firstDevice)
let program = try Program(context: context, programPath: vecAddFilePath)
try program.build(firstDevice)

let kernel = try Kernel(program: program, kernelName: "vec_add")

var timeTaken: NSTimeInterval = 0.0

let elements = 2048 * 10

var a = Array<cl_int4>(count: elements / 4, repeatedValue:cl_int4(s: (0, 0, 0, 0)))
var b = Array<cl_int4>(count: elements / 4, repeatedValue:cl_int4(s: (0, 0, 0, 0)))

for idx in 0.stride(through: (elements - 1)/4, by: 4) {
	let clIdx = cl_int(idx)
	a[idx] = cl_int4(s: (clIdx, clIdx+1, clIdx+2, clIdx+3))
	b[idx] = cl_int4(s: (clIdx, clIdx+1, clIdx+2, clIdx+3))
}

var start = NSDate()

let aBuffer = try Buffer(context: context, readOnlyData: a)
let bBuffer = try Buffer(context: context, readOnlyData: b)
let cBuffer = try Buffer<cl_int4>(context: context, count: elements / 4)

try kernel.setArg(0, buffer: aBuffer)
try kernel.setArg(1, buffer: bBuffer)
try kernel.setArg(2, buffer: cBuffer)

try commandQueue.enqueueNDRangeKernel(kernel,
	offset: NDRange(size: 0),
	global: NDRange(size: elements / 4))

var c = cBuffer.enqueueRead(commandQueue)

timeTaken = NSDate().timeIntervalSinceDate(start)

for idx in 0..<(elements - 1) / 4 {
	assert(c[idx].s.0 == a[idx].s.0 + b[idx].s.0)
	assert(c[idx].s.1 == a[idx].s.1 + b[idx].s.1)
	assert(c[idx].s.2 == a[idx].s.2 + b[idx].s.2)
	assert(c[idx].s.3 == a[idx].s.3 + b[idx].s.3)
}

// Normal add
start = NSDate()
var normalA = Array<cl_int>(0..<cl_int(elements))
var normalB = normalA
var normalC = Array<cl_int>(count: elements, repeatedValue: cl_int(0))
for idx in 0..<elements {
	normalC[idx] = normalA[idx] + normalB[idx]
}

timeTaken = NSDate().timeIntervalSinceDate(start)

start = NSDate()
vDSP_vaddi(&normalA, 1, &normalB, 1, &normalC, 1, vDSP_Length(elements))
timeTaken = NSDate().timeIntervalSinceDate(start)