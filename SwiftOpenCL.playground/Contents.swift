//: Playground - noun: a place where people can play

import Foundation
import OpenCL

let vecAddFilePath = NSBundle.mainBundle().pathForResource("vec_add", ofType: "cl")
let vecAdd = try! String(contentsOfFile: vecAddFilePath!, encoding: NSUTF8StringEncoding)

let platforms = Platform.allPlatforms()
let devices = platforms.first!.getDevices(CL_DEVICE_TYPE_CPU)

let context = Context(devices: devices)
let commandQueue = CommandQueue(context: context, device: devices.first!)
let program = Program(context: context, programSource: vecAdd)
program?.build(devices.first!)
let kernel = Kernel(program: program!, kernelName: "vec_add")!

let times = 10
var timeTaken: NSTimeInterval = 0.0
//for index in 1...times {//

	let elements = 2048// * index

var a = Array<cl_int>(count: elements, repeatedValue: cl_int())

for idx in 0..<(elements) {
	a[idx] = cl_int(idx)
}

var b = a

let start = NSDate()

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
timeTaken = NSDate().timeIntervalSinceDate(start)


