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
}

class CommandQueue {
	let queue: cl_command_queue
	init(context: Context, device: Device, properties: cl_command_queue_properties = 0) {
		queue = clCreateCommandQueue(context.context, device.deviceId, properties, nil)
	}
}

class Program {
	
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

let device = Device.getDefault(CL_DEVICE_TYPE_CPU)
device.getStringInfo(CL_DEVICE_NAME)

let queue = GclCommandQueue(deviceType: CL_DEVICE_TYPE_GPU)
let queueDevice = queue.getDevice()
queueDevice.getStringInfo(CL_DEVICE_NAME)
queueDevice.getGenericInfo(CL_DEVICE_ADDRESS_BITS, infoType: cl_uint.self)
queueDevice.getStringInfo(CL_DEVICE_EXTENSIONS)

let platforms = Platform.allPlatforms()
println(platforms.first)
println(platforms.first?.getDevices(CL_DEVICE_TYPE_CPU))






