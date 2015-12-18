import OpenCL

public class Buffer<T> {
	public var buffer: cl_mem
	var size: Int
	var count: Int
	
	public init(context: Context, var readOnlyData: [T]) {
		count = readOnlyData.count
		size = sizeof(T) * count
		buffer = clCreateBuffer(context.context, cl_mem_flags(CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR), size, &readOnlyData, nil)
	}
	
	public init(context: Context, count: Int) {
		size = sizeof(T) * count
		self.count = count
		buffer = clCreateBuffer(context.context, cl_mem_flags(CL_MEM_WRITE_ONLY), size, nil, nil)
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
