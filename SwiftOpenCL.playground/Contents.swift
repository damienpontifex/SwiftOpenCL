//: Playground - noun: a place where people can play

import Foundation
import OpenCL

//let device = Device.getDefault(CL_DEVICE_TYPE_CPU)
//device.getStringInfo(CL_DEVICE_NAME)
//
//let queue = GclCommandQueue(deviceType: CL_DEVICE_TYPE_GPU)
//let queueDevice = queue.getDevice()
//queueDevice.getStringInfo(CL_DEVICE_NAME)
//queueDevice.getGenericInfo(CL_DEVICE_ADDRESS_BITS, infoType: cl_uint.self)
//queueDevice.getStringInfo(CL_DEVICE_EXTENSIONS)

let vecAdd =
"__kernel                                            \n" +
	"void vecadd(__global int *A,                        \n" +
	"            __global int *B,                        \n" +
	"            __global int *C)                        \n" +
	"{                                                   \n" +
	"                                                    \n" +
	"   // Get the work-item’s unique ID                 \n" +
	"   int idx = get_global_id(0);                      \n" +
	"                                                    \n" +
	"   // Add the corresponding locations of            \n" +
	"   // 'A' and 'B', and store the result in 'C'.     \n" +
	"   C[idx] = A[idx] + B[idx];                        \n" +
"}                                                   \n"

let platforms = Platform.allPlatforms()
let devices = platforms.first!.getDevices(CL_DEVICE_TYPE_GPU)

let context = Context(devices: devices)
let commandQueue = CommandQueue(context: context, device: devices.first!)
let program = Program(context: context, programSource: vecAdd)
program.build(devices.first!)
let kernel = Kernel(program: program, kernelName: "vecadd")

let times = 8
var timeTaken: NSTimeInterval = 0.0
//for index in 1...times {
	let start = NSDate()
	let elements = 2048 // * index
	var a = Array<cl_int>(count: elements, repeatedValue: cl_int(0))
	var b = a
	for i in 0..<2048 {
		a[i] = cl_int(i)
		b[i] = cl_int(i)
	}
	
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

	let c = cBuffer.enqueueRead(commandQueue)

	print(c)
	timeTaken = NSDate().timeIntervalSinceDate(start)
//}







































