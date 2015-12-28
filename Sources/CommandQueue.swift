import OpenCL

public class CommandQueue {
	public let queue: cl_command_queue
	
	public init(context: Context, device: Device, properties: cl_command_queue_properties = 0) throws {
		var err: cl_int = CL_SUCCESS
		queue = clCreateCommandQueue(context.context, device.deviceId, properties, &err)
		
		try ClError.check(err)
	}
}
