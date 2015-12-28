import OpenCL

public class Buffer<T> {
	public var buffer: cl_mem
	var size: Int
	var count: Int
	
	public init(context: Context, memFlags: cl_mem_flags, var data: [T]) throws {
		count = data.count
		size = sizeof(T) * count
		
		var err: cl_int = CL_SUCCESS
		buffer = clCreateBuffer(context.context, memFlags, size, &data, &err)
		
		try ClError.check(err)
	}
	
	public convenience init(context: Context, readOnlyData: [T]) throws {
		try self.init(context: context, memFlags: cl_mem_flags(CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR), data: readOnlyData)
	}
	
	public init(context: Context, count: Int) throws {
		size = sizeof(T) * count
		self.count = count
		
		var err: cl_int = CL_SUCCESS
		buffer = clCreateBuffer(context.context, cl_mem_flags(CL_MEM_WRITE_ONLY), size, nil, &err)
		
		try ClError.check(err)
	}
	
	public func enqueueRead(queue: CommandQueue) -> [T] {
		let elements = UnsafeMutablePointer<T>.alloc(count)
		
		clEnqueueReadBuffer(queue.queue, buffer, cl_bool(CL_TRUE), 0, size, elements, 0, nil, nil)
		
		let array = Array<T>(UnsafeBufferPointer(start: elements, count: count))
		elements.dealloc(count)
		
		return array
	}
	
	public func enqueueWrite(queue: CommandQueue, data: [T]) {
		//		clEnqueueWriteBuffer(queue.queue, buffer, <#T##cl_bool#>, <#T##Int#>, <#T##Int#>, <#T##UnsafePointer<Void>#>, <#T##cl_uint#>, <#T##UnsafePointer<cl_event>#>, <#T##UnsafeMutablePointer<cl_event>#>)
	}
	
	deinit {
		clReleaseMemObject(buffer)
	}
}
