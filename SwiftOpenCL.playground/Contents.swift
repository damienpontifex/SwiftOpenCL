//: Playground - noun: a place where people can play

import OpenCL

class Wrapper<T> {
	var object: T?
}

protocol Initable {
	init()
}
extension String: Initable {}
extension cl_uint: Initable {}
extension CChar: Initable {}

class Platform : Printable {
	var platformId: cl_platform_id
	init(id: cl_platform_id) {
		platformId = id
	}
	
	var description: String {
		let version = getInfo(CL_PLATFORM_VERSION) ?? "Unknown Version"
		let name = getInfo(CL_PLATFORM_NAME) ?? "No Platform"
		return name + " Platform running " + version
	}
	
	class func allPlatforms() -> [Platform] {
		var platformCount: cl_uint = 0
		clGetPlatformIDs(0, nil, &platformCount)
		
		var platformIds = Array<cl_platform_id>(count: Int(platformCount), repeatedValue: cl_platform_id())
		//		UnsafeMutablePointer<cl_platform_id>.alloc(Int(platformCount))
		
		clGetPlatformIDs(platformCount, &platformIds, nil)
		
		let platforms = map(platformIds) {
			Platform(id: $0)
		}
		
		return platforms
	}
	
	func getInfo(info: Int32) -> String? {
		
		var infoSize: Int = 0
		clGetPlatformInfo(platformId, cl_platform_info(info), 0, nil, &infoSize)
		
		var infoArray = Array<CChar>(count: infoSize, repeatedValue: CChar(32))
		clGetPlatformInfo(platformId, cl_platform_info(info), infoSize, &infoArray, nil)
		
		let infoString = String.fromCString(&infoArray)
		return infoString
	}
	
	func getDevices(deviceType: Int32) -> [Device] {
		
		var deviceCount: cl_uint = 0
		clGetDeviceIDs(platformId, cl_device_type(deviceType), 0, nil, &deviceCount)
		
		var deviceIds = Array<cl_device_id>(count: Int(deviceCount), repeatedValue: cl_device_id())
		
		clGetDeviceIDs(platformId, cl_device_type(deviceType), deviceCount, &deviceIds, nil)
		
		let devices = map(deviceIds) {
			Device(id: $0)
		}
		
		return devices
	}
}

class Context {
	let context: cl_context
	init(devices: [Device]) {
		
		let numDevices = devices.count
		var deviceIds = map(devices) {
			$0.deviceId
		}
		
		context = clCreateContext(nil, cl_uint(numDevices), &deviceIds, nil, nil, nil)
	}
	
	deinit {
		clReleaseContext(context)
	}
}

class CommandQueue {
	let queue: cl_command_queue
	init(context: Context, device: Device, properties: cl_command_queue_properties = 0) {
		queue = clCreateCommandQueue(context.context, device.deviceId, properties, nil)
	}
}

class Program {
	var program: cl_program!
	
	init(context: Context, programSource: String) {
		
		programSource.withCString() { cString -> Void in
			let pointer = UnsafeMutablePointer<UnsafePointer<Int8>>(cString)
			self.program = clCreateProgramWithSource(context.context, 1, pointer, nil, nil)
			return Void()
		}
	}
	
	func build(device: Device) {
		clBuildProgram(program,
			1,
			&device.deviceId,
			nil,
			nil,
			nil)
	}
	
	deinit {
		if program != nil {
			clReleaseProgram(program)
		}
	}
}

class Kernel {
	var kernel: cl_kernel!
	
	init(program: Program, kernelName: String) {
		kernelName.withCString() { cKernelName in
			self.kernel = clCreateKernel(
				program.program,
				cKernelName,
				nil)
		}
	}
	
	deinit {
		if kernel != nil {
			clReleaseKernel(kernel)
		}
	}
}

class GclCommandQueue {
	let queue: dispatch_queue_t
	init(deviceType: Int32) {
		queue = gcl_create_dispatch_queue(cl_queue_flags(deviceType), nil)
	}
	
	func getDevice() -> Device {
		let deviceId = gcl_get_device_id_with_dispatch_queue(queue)
		return Device(id: deviceId)
	}
}

class Device: Printable {
	
	var deviceId: cl_device_id
	
	init(id: cl_device_id) {
		deviceId = id
	}
	
	var description: String {
		return getStringInfo(CL_DEVICE_NAME) ?? "<No Device Name>"
	}
	
	class func getDefault(type: Int32) -> Device {
		let queue = gcl_create_dispatch_queue(cl_queue_flags(type), nil)
		
		let deviceId = gcl_get_device_id_with_dispatch_queue(queue)
		
		var device = Device(id: deviceId)
		return device
	}
	
	func getGenericInfo<T: Initable>(deviceInfo: Int32, infoType: T.Type) -> [T]? {
		
		// Determine the size of the value returned
		var valueSize: size_t = 0
		clGetDeviceInfo(deviceId, cl_device_info(deviceInfo), 0, nil, &valueSize)
		
		var value = Array<T>(count: valueSize, repeatedValue: T())
		
		// Actually get the value
		clGetDeviceInfo(self.deviceId, cl_device_info(deviceInfo), valueSize, &value, nil)
		
		return value
	}
	
	func getStringInfo(deviceInfo: Int32) -> String? {
		if var cString = getGenericInfo(deviceInfo, infoType: CChar.self) {
			return String.fromCString(&cString)
		}
		
		return nil
	}
}

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
let devices = platforms.first!.getDevices(CL_DEVICE_TYPE_CPU)

let context = Context(devices: devices)
let commandQueue = CommandQueue(context: context, device: devices.first!)

// Create and compile program
let program = Program(context: context, programSource: vecAdd)
program.build(devices.first!)
// Create kernel
let kernel = Kernel(program: program, kernelName: "vecadd")
// Buffers
// Write host data to buffers
// Set kernal arguments
var a = [1, 2, 3, 4, 5, 6, 7, 8]
var b = a
var c = a
let memA = UnsafeMutablePointer<Void>(a)
let memB = UnsafeMutablePointer<Void>(b)
var aBuffer = clCreateBuffer(context.context, cl_mem_flags(CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR), sizeof(Int) * 8, memA, nil) as cl_mem
var bBuffer = clCreateBuffer(context.context, cl_mem_flags(CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR), sizeof(Int) * 8, memB, nil) as cl_mem
var cBuffer = clCreateBuffer(context.context, cl_mem_flags(CL_MEM_WRITE_ONLY), sizeof(Int) * 8, nil, nil) as cl_mem

clSetKernelArg(kernel.kernel, 0, sizeof(cl_mem), &aBuffer)
clSetKernelArg(kernel.kernel, 1, sizeof(cl_mem), &bBuffer)
clSetKernelArg(kernel.kernel, 2, sizeof(cl_mem), &cBuffer)
// Configure work-item structure
var ndRange = cl_ndrange()
// Enqueue kernel for execution
var itemCount = 0
clEnqueueNDRangeKernel(commandQueue.queue,
 kernel.kernel,
	cl_uint(1),
	nil,
	&itemCount,
	nil,
	0,
	nil,
	nil)
// Read output buffer back to host
clEnqueueReadBuffer(commandQueue.queue, cBuffer, CL_TRUE, 0, sizeof(Int) * 8, &c, 0, nil, nil)
// Release any resources
println(c)

clReleaseMemObject(aBuffer)
clReleaseMemObject(bBuffer)
clReleaseMemObject(cBuffer)








































