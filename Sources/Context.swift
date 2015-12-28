import OpenCL

public class Context {
	public let context: cl_context
	
	public init(devices: [Device]) throws {
		
		let numDevices = devices.count
		var deviceIds = devices.map {
			$0.deviceId
		}
		
		var err: cl_int = CL_SUCCESS
		context = clCreateContext(nil, cl_uint(numDevices), &deviceIds, nil, nil, &err)
		
		try ClError.check(err)
	}
	
	public convenience init(device: Device) throws {
		try self.init(devices: [device])
	}
	
	public init(type: cl_device_type) throws {
		var err: cl_int = CL_SUCCESS
		context = clCreateContextFromType(nil, type, nil, nil, &err)
		
		try ClError.check(err)
	}
	
	deinit {
		clReleaseContext(context)
	}
	
	public class func getDefault() throws -> Context {
		return try Context(type: cl_device_type(CL_DEVICE_TYPE_DEFAULT))
	}
	
	public func getInfo<T>(info: cl_context_info, type: T.Type) throws -> [T]? {
		// Determine the size of the value returned
		var valueSize: size_t = 0
		clGetContextInfo(context, cl_context_info(info), 0, nil, &valueSize)
		
		let value = UnsafeMutablePointer<T>.alloc(valueSize / sizeof(type))
		
		// Actually get the value
		clGetContextInfo(context, cl_device_info(info), valueSize, value, nil)
		
		let array = Array<T>(UnsafeBufferPointer(start: value, count: valueSize))
		value.dealloc(valueSize)
		
		return array
	}
}