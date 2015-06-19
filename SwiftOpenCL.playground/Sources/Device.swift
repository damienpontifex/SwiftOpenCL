import Foundation
import OpenCL

public class Device: Printable {
	
	public var deviceId: cl_device_id
	
	public init(id: cl_device_id) {
		deviceId = id
	}
	
	public var description: String {
		return getStringInfo(CL_DEVICE_NAME) ?? "<No Device Name>"
	}
	
	public class func getDefault(type: Int32) -> Device {
		let queue = gcl_create_dispatch_queue(cl_queue_flags(type), nil)
		
		let deviceId = gcl_get_device_id_with_dispatch_queue(queue!)
		
		let device = Device(id: deviceId)
		return device
	}
	
	public func getGenericInfo<T>(deviceInfo: Int32, infoType: T.Type) -> [T]? {
		
		// Determine the size of the value returned
		var valueSize: size_t = 0
		clGetDeviceInfo(deviceId, cl_device_info(deviceInfo), 0, nil, &valueSize)
		
		let value = UnsafeMutablePointer<T>.alloc(valueSize)
		
		// Actually get the value
		clGetDeviceInfo(self.deviceId, cl_device_info(deviceInfo), valueSize, value, nil)
		
		let array = Array<T>(UnsafeBufferPointer(start: value, count: valueSize))
		value.dealloc(valueSize)
		
		return array
	}
	
	public func getStringInfo(deviceInfo: Int32) -> String? {
		if var cString = getGenericInfo(deviceInfo, infoType: CChar.self) {
			return String.fromCString(&cString)
		}
		
		return nil
	}
}
