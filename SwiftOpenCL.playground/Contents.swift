//: Playground - noun: a place where people can play

import Foundation
import OpenCL
import Accelerate

//let device = Device.getDefault(CL_DEVICE_TYPE_CPU)
//device.getStringInfo(CL_DEVICE_NAME)
//
//let queue = GclCommandQueue(deviceType: CL_DEVICE_TYPE_GPU)
//let queueDevice = queue.getDevice()
//queueDevice.getStringInfo(CL_DEVICE_NAME)
//queueDevice.getGenericInfo(CL_DEVICE_ADDRESS_BITS, infoType: cl_uint.self)
//queueDevice.getStringInfo(CL_DEVICE_EXTENSIONS)

let vecAddFilePath = NSBundle.mainBundle().pathForResource("vec_add", ofType: "cl")
let vecAdd = NSString(contentsOfFile: vecAddFilePath!, encoding: NSUTF8StringEncoding, error: nil) as! String

let platforms = Platform.allPlatforms()
let devices = platforms.first!.getDevices(CL_DEVICE_TYPE_CPU)

let context = Context(devices: devices)
let commandQueue = CommandQueue(context: context, device: devices.first!)
let program = Program(context: context, programSource: vecAdd)
program.build(devices.first!)
let kernel = Kernel(program: program, kernelName: "vec_add")

let times = 10
var timeTaken: NSTimeInterval = 0.0
//for index in 1...times {//

	let elements = 2048// * index

	var a = map(0..<elements) {
		cl_int($0)
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

let accelerateStartDate = NSDate()

var a32: [Int32] = a
var b32: [Int32] = b
var c32: [Int32] = c

vDSP_vaddi(a32, 1, b32, 1, &c32, 1, vDSP_Length(elements))

print(c)

NSDate().timeIntervalSinceDate(accelerateStartDate)



//}







































