//: Playground - noun: a place where people can play

import OpenCL

enum ClError: cl_int, ErrorType {
	// run-time and JIT compiler errors
	case CL_SUCCESS = 0
	case CL_DEVICE_NOT_FOUND = -1
	case CL_DEVICE_NOT_AVAILABLE = -2
	case CL_COMPILER_NOT_AVAILABLE = -3
	case CL_MEM_OBJECT_ALLOCATION_FAILURE = -4
	case CL_OUT_OF_RESOURCES = -5
	case CL_OUT_OF_HOST_MEMORY = -6
	case CL_PROFILING_INFO_NOT_AVAILABLE = -7
	case CL_MEM_COPY_OVERLAP = -8
	case CL_IMAGE_FORMAT_MISMATCH = -9
	case CL_IMAGE_FORMAT_NOT_SUPPORTED = -10
	case CL_BUILD_PROGRAM_FAILURE = -11
	case CL_MAP_FAILURE = -12
	case CL_MISALIGNED_SUB_BUFFER_OFFSET = -13
	case CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST = -14
	case CL_COMPILE_PROGRAM_FAILURE = -15
	case CL_LINKER_NOT_AVAILABLE = -16
	case CL_LINK_PROGRAM_FAILURE = -17
	case CL_DEVICE_PARTITION_FAILED = -18
	case CL_KERNEL_ARG_INFO_NOT_AVAILABLE = -19
	
	// compile-time errors
	case CL_INVALID_VALUE = -30
	case CL_INVALID_DEVICE_TYPE = -31
	case CL_INVALID_PLATFORM = -32
	case CL_INVALID_DEVICE = -33
	case CL_INVALID_CONTEXT = -34
	case CL_INVALID_QUEUE_PROPERTIES = -35
	case CL_INVALID_COMMAND_QUEUE = -36
	case CL_INVALID_HOST_PTR = -37
	case CL_INVALID_MEM_OBJECT = -38
	case CL_INVALID_IMAGE_FORMAT_DESCRIPTOR = -39
	case CL_INVALID_IMAGE_SIZE = -40
	case CL_INVALID_SAMPLER = -41
	case CL_INVALID_BINARY = -42
	case CL_INVALID_BUILD_OPTIONS = -43
	case CL_INVALID_PROGRAM = -44
	case CL_INVALID_PROGRAM_EXECUTABLE = -45
	case CL_INVALID_KERNEL_NAME = -46
	case CL_INVALID_KERNEL_DEFINITION = -47
	case CL_INVALID_KERNEL = -48
	case CL_INVALID_ARG_INDEX = -49
	case CL_INVALID_ARG_VALUE = -50
	case CL_INVALID_ARG_SIZE = -51
	case CL_INVALID_KERNEL_ARGS = -52
	case CL_INVALID_WORK_DIMENSION = -53
	case CL_INVALID_WORK_GROUP_SIZE = -54
	case CL_INVALID_WORK_ITEM_SIZE = -55
	case CL_INVALID_GLOBAL_OFFSET = -56
	case CL_INVALID_EVENT_WAIT_LIST = -57
	case CL_INVALID_EVENT = -58
	case CL_INVALID_OPERATION = -59
	case CL_INVALID_GL_OBJECT = -60
	case CL_INVALID_BUFFER_SIZE = -61
	case CL_INVALID_MIP_LEVEL = -62
	case CL_INVALID_GLOBAL_WORK_SIZE = -63
	case CL_INVALID_PROPERTY = -64
	case CL_INVALID_IMAGE_DESCRIPTOR = -65
	case CL_INVALID_COMPILER_OPTIONS = -66
	case CL_INVALID_LINKER_OPTIONS = -67
	case CL_INVALID_DEVICE_PARTITION_COUNT = -68
	
	// extension errors
	case CL_INVALID_GL_SHAREGROUP_REFERENCE_KHR = -1000
	case CL_PLATFORM_NOT_FOUND_KHR = -1001
	case CL_INVALID_D3D10_DEVICE_KHR = -1002
	case CL_INVALID_D3D10_RESOURCE_KHR = -1003
	case CL_D3D10_RESOURCE_ALREADY_ACQUIRED_KHR = -1004
	case CL_D3D10_RESOURCE_NOT_ACQUIRED_KHR = -1005
	case CL_UNKNOWN_ERROR = -999999
}

class Wrapper<T> {
	var object: T?
}

protocol Initable {
	init()
}
extension String: Initable {}
extension cl_uint: Initable {}
extension CChar: Initable {}

class Platform : CustomStringConvertible {
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
		
		let platforms = platformIds.map {
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
		
		let devices = deviceIds.map {
			Device(id: $0)
		}
		
		return devices
	}
}

class Context {
	let context: cl_context
	init(devices: [Device]) {
		
		let numDevices = devices.count
		var deviceIds = devices.map {
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
	var program: cl_program
	
	init(context: Context, programSource: String) throws {
		
		var status: cl_int = CL_SUCCESS
		program = programSource.withCString() { (var cString) -> cl_program in
			return withUnsafeMutablePointer(&cString) { mutableCString -> cl_program in
				let sourceProgram = clCreateProgramWithSource(context.context, 1, mutableCString, nil, &status)
				return sourceProgram
			}
		}
		if status != CL_SUCCESS {
			let error = ClError(rawValue: status) ?? ClError.CL_UNKNOWN_ERROR
			print("Create program error \(error)")
			throw error
		}
	}
	
	func build(device: Device) {
		let status = clBuildProgram(program,
			1,
			&device.deviceId,
			nil,
			nil,
			nil)
		
		if status != CL_SUCCESS {
			print("Build program error \(status)")
			var length: Int = 0
			clGetProgramBuildInfo(program, device.deviceId, cl_program_build_info(CL_PROGRAM_BUILD_LOG), 0, nil, &length)
			
			var value = Array<CChar>(count: length, repeatedValue: CChar(32))
			clGetProgramBuildInfo(program, device.deviceId, cl_program_build_info(CL_PROGRAM_BUILD_LOG), length, &value, nil)
			print("Build log \(String.fromCString(&value))")
		}
	}
	
	deinit {
		if program != nil {
			clReleaseProgram(program)
		}
	}
}

class Buffer<T> {
	var buffer: cl_mem
	var size: Int
	var count: Int
	
	init(context: Context, var readOnlyData: [T]) {
		count = readOnlyData.count
		size = sizeof(T) * count
		buffer = clCreateBuffer(context.context, cl_mem_flags(CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR), size, &readOnlyData, nil)
	}
	
	init(context: Context, count: Int) {
		size = sizeof(T) * count
		self.count = count
		buffer = clCreateBuffer(context.context, cl_mem_flags(CL_MEM_WRITE_ONLY), size, nil, nil)
	}
	
	func enqueueRead(queue: CommandQueue) -> [T] {
		let elements = UnsafeMutablePointer<T>.alloc(count)
		
		clEnqueueReadBuffer(queue.queue, buffer, cl_bool(CL_TRUE), 0, size, elements, 0, nil, nil)
		
		let array = Array<T>(UnsafeBufferPointer(start: elements, count: count))
		elements.dealloc(count)
		
		return array
	}
	
	func enqueueWrite(queue: CommandQueue, data: [T]) {
		//		clEnqueueWriteBuffer(queue.queue, buffer, <#T##cl_bool#>, <#T##Int#>, <#T##Int#>, <#T##UnsafePointer<Void>#>, <#T##cl_uint#>, <#T##UnsafePointer<cl_event>#>, <#T##UnsafeMutablePointer<cl_event>#>)
	}
	
	deinit {
		clReleaseMemObject(buffer)
	}
}

class Kernel {
	var kernel: cl_kernel
	
	init(program: Program, kernelName: String) {
		
		kernel = kernelName.withCString() { cKernelName -> cl_kernel in
			var status: cl_int = CL_SUCCESS
			let sourceKernel = clCreateKernel(
				program.program,
				cKernelName,
				&status)
			
			if status != CL_SUCCESS {
				print("Create kernel error \(status)")
			}
			
			return sourceKernel
		}
	}
	
	func setArg<T>(position: cl_uint, buffer: Buffer<T>) -> cl_int {
		return clSetKernelArg(kernel, position, sizeof(cl_mem), &(buffer.buffer))
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
		queue = gcl_create_dispatch_queue(cl_queue_flags(deviceType), nil)!
	}
	
	func getDevice() -> Device {
		let deviceId = gcl_get_device_id_with_dispatch_queue(queue)
		return Device(id: deviceId)
	}
}

class Device: CustomStringConvertible {
	
	var deviceId: cl_device_id
	
	init(id: cl_device_id) {
		deviceId = id
	}
	
	var description: String {
		return getStringInfo(CL_DEVICE_NAME) ?? "<No Device Name>"
	}
	
	class func getDefault(type: Int32) -> Device {
		let queue = gcl_create_dispatch_queue(cl_queue_flags(type), nil)
		
		let deviceId = gcl_get_device_id_with_dispatch_queue(queue!)
		
		let device = Device(id: deviceId)
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
let program = try Program(context: context, programSource: vecAdd)
program.build(devices.first!)
// Create kernel
let kernel = Kernel(program: program, kernelName: "vecadd")
// Buffers
// Write host data to buffers
// Set kernal arguments
let elements = 2048
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

// Configure work-item structure
// Enqueue kernel for execution
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
// Read output buffer back to host
let c = cBuffer.enqueueRead(commandQueue)
// Release any resources
print(c)








































