//: Playground - noun: a place where people can play

import Foundation
import OpenCL
import SwiftOpenCL
import XCPlayground

let vecAddFilePath = NSBundle.mainBundle().pathForResource("vec_add", ofType: "cl")
let vecAdd = try! String(contentsOfFile: vecAddFilePath!, encoding: NSUTF8StringEncoding)

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
guard let program = Program(context: context, programSource: vecAdd) else {
	XCPlaygroundPage.currentPage.finishExecution()
}
program.build(firstDevice)
let kernel = try Kernel(program: program, kernelName: "vec_add")
let times = 10
var timeTaken: NSTimeInterval = 0.0

for index in 0...5 {
	let elements = 2048 * index
	
	var a = Array(0..<cl_int(elements))
	var b = a
	
	let start = NSDate()
	
	let aBuffer = Buffer(context: context, readOnlyData: a)
	let bBuffer = Buffer(context: context, readOnlyData: b)
	let cBuffer = Buffer<cl_int>(context: context, count: elements)
	
	try kernel.setArg(0, buffer: aBuffer)
	try kernel.setArg(1, buffer: bBuffer)
	try kernel.setArg(2, buffer: cBuffer)
	
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
	timeTaken = NSDate().timeIntervalSinceDate(start)
}


