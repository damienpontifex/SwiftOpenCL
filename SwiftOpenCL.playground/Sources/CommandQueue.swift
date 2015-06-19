import Foundation
import OpenCL

public class CommandQueue {
	public let queue: cl_command_queue
	public init(context: Context, device: Device, properties: cl_command_queue_properties = 0) {
		queue = clCreateCommandQueue(context.context, device.deviceId, properties, nil)
	}
}
