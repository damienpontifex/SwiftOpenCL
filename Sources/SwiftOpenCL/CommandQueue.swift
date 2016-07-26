import OpenCL

public class CommandQueue {
	public let queue: cl_command_queue
	
	public init(context: Context, device: Device, properties: cl_command_queue_properties = 0) throws {
		var err: cl_int = CL_SUCCESS
		queue = clCreateCommandQueue(context.context, device.deviceId, properties, &err)
		
		try ClError.check(err)
	}
	
	public func enqueueNDRangeKernel(_ kernel: Kernel, offset: NDRange, global: NDRange) throws {
		
		var globalWorkOffset = offset.sizes[0]
		var globalWorkSize = global.sizes[0]
		
		let err = clEnqueueNDRangeKernel(
			queue, 
			kernel.kernel, 
			global.dimensions,
			&globalWorkOffset,
			&globalWorkSize, 
			nil,
			0,
			nil,
			nil)
		
		try ClError.check(err)
	}
}
