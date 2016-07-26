import OpenCL

public enum DeviceType {
	case cpu
	case gpu
	case all
	
	var nativeType: cl_device_type {
		switch self {
		case .all:
			return cl_device_type(CL_DEVICE_TYPE_ALL)
		case .gpu:
			return cl_device_type(CL_DEVICE_TYPE_GPU)
		case .cpu:
			fallthrough
		default:
			return cl_device_type(CL_DEVICE_TYPE_CPU)
		}
	}
}

public class Device: CustomStringConvertible {
	
	public var deviceId: cl_device_id
	
	public init(id: cl_device_id) {
		deviceId = id
	}
	
	public class func `default`(_ deviceType: DeviceType = .gpu) -> Device? {
		return Platform.all.first?.getDevices(deviceType).first
	}
	
	public var name: String {
		guard var chars: [CChar] = getDeviceInfo(CL_DEVICE_NAME, deviceId: deviceId) else {
			return "<No Device Name>"
		}
		return String(cString: &chars)
	}
	
	public var description: String {
		return name
	}
	
	public class func getDefault(_ type: Int32) -> Device {
		let queue = gcl_create_dispatch_queue(cl_queue_flags(type), nil)
		
		let deviceId = gcl_get_device_id_with_dispatch_queue(queue!)
		
		let device = Device(id: deviceId!)
		return device
	}
	
	public func getInfo<T>(_ deviceInfo: Int32) -> [T]? {
		
		// Determine the size of the value returned
		var valueSize: size_t = 0
		clGetDeviceInfo(deviceId, cl_device_info(deviceInfo), 0, nil, &valueSize)
		
		let value = UnsafeMutablePointer<T>(allocatingCapacity: valueSize)
		
		// Actually get the value
		clGetDeviceInfo(self.deviceId, cl_device_info(deviceInfo), valueSize, value, nil)
		
		let array = Array<T>(UnsafeBufferPointer(start: value, count: valueSize))
		value.deallocateCapacity(valueSize)
		
		return array
	}
	
	public func getStringInfo(_ deviceInfo: Int32) -> String? {
		if var cString: [CChar] = getInfo(deviceInfo) {
			return String(cString: &cString)
		}
		
		return nil
	}
}

func getDeviceInfo<T>(_ deviceInfo: Int32, deviceId: cl_device_id) -> [T]? {
	// Determine the size of the value returned
	var valueSize: size_t = 0
	clGetDeviceInfo(deviceId, cl_device_info(deviceInfo), 0, nil, &valueSize)
	
	// Allocate some memory for the value
	let value = UnsafeMutablePointer<T>(allocatingCapacity: valueSize)
	
	// Actually get the value
	clGetDeviceInfo(deviceId, cl_device_info(deviceInfo), valueSize, value, nil)
	
	// Conver the memory to a Swift array for easier handling
	let array = Array<T>(UnsafeBufferPointer(start: value, count: valueSize))
	// Deallocate our manual memory
	value.deallocateCapacity(valueSize)
	
	return array
}
