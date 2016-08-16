import OpenCL

public class Context {
	public let context: cl_context
	
	public init(devices: [Device]) throws {
		
		let numDevices = devices.count
		let deviceIds: [cl_device_id?] = devices.map {
			$0.deviceId
		}
		
		context = try deviceIds.withUnsafeBufferPointer { idBuffer -> cl_context in
			
			guard let idBase = idBuffer.baseAddress else {
				//TODO: throw valid error
				throw ClError(err: 0)
			}
			
			var err: cl_int = CL_SUCCESS
			guard let newContext = clCreateContext(nil, cl_uint(numDevices), idBase, nil, nil, &err) else {
				//TODO: throw valid error
				throw ClError(err: 0)
			}
			
			try ClError.check(err)
			
			return newContext
		}
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
	
	public func getInfo<T>(_ info: cl_context_info, type: T.Type) throws -> [T]? {
		// Determine the size of the value returned
		var valueSize: size_t = 0
		clGetContextInfo(context, cl_context_info(info), 0, nil, &valueSize)
		
		let value = UnsafeMutablePointer<T>.allocate(capacity: valueSize / MemoryLayout<T>.size)
		
		// Actually get the value
		clGetContextInfo(context, cl_device_info(info), valueSize, value, nil)
		
		let array = Array<T>(UnsafeBufferPointer(start: value, count: valueSize))
		value.deallocate(capacity: valueSize)
		
		return array
	}
}
