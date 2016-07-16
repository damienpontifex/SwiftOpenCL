import OpenCL

public class Device: CustomStringConvertible {
	
	public var deviceId: cl_device_id
	
	public init(id: cl_device_id) {
		deviceId = id
	}
	
	class func getDefault() throws -> Device {
		let context = try Context.getDefault()
		
		guard let device = try context.getInfo(cl_context_info(CL_CONTEXT_DEVICES), type: cl_device_id.self)?.first else {
			throw ClError(err: CL_DEVICE_NOT_FOUND)
		}
		
		return Device(id: device)
	}
	
	public var description: String {
		return getStringInfo(CL_DEVICE_NAME) ?? "<No Device Name>"
	}
	
	public class func getDefault(_ type: Int32) -> Device {
		let queue = gcl_create_dispatch_queue(cl_queue_flags(type), nil)
		
		let deviceId = gcl_get_device_id_with_dispatch_queue(queue!)
		
		let device = Device(id: deviceId!)
		return device
	}
	
	public func getInfo<T>(_ deviceInfo: Int32, infoType: T.Type) -> [T]? {
		
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
		if var cString = getInfo(deviceInfo, infoType: CChar.self) {
			return String(cString: &cString)
		}
		
		return nil
	}
}
