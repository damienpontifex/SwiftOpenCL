import OpenCL

public class GclCommandQueue {
	public let queue: DispatchQueue
	public init(deviceType: Int32) {
		queue = gcl_create_dispatch_queue(cl_queue_flags(deviceType), nil)!
	}
	
	public func getDevice() -> Device {
		let deviceId = gcl_get_device_id_with_dispatch_queue(queue)
		return Device(id: deviceId!)
	}
}
