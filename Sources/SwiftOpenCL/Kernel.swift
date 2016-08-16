import OpenCL

public class Kernel {
	public var kernel: cl_kernel?
	
	public init(program: Program, kernelName: String) throws {
		
		var status: cl_int = CL_SUCCESS
		
		kernel = kernelName.withCString() { cKernelName -> cl_kernel in
			let sourceKernel = clCreateKernel(
				program.program,
				cKernelName,
				&status)
			
			return sourceKernel!
		}
		
		try ClError.check(status)
	}
	
	public func setArg<T>(_ position: cl_uint, buffer: Buffer<T>) throws {
		let err = clSetKernelArg(kernel, position, MemoryLayout<cl_mem>.size, &(buffer.buffer))
		
		try ClError.check(err)
	}
	
	public func setArgs<T>(_ buffer: Buffer<T>...) throws {
		for (idx, item) in buffer.enumerated() {
			let err = clSetKernelArg(kernel, cl_uint(idx), MemoryLayout<cl_mem>.size, &(item.buffer))
			
			try ClError.check(err)
		}
	}
	
	deinit {
		if kernel != nil {
			clReleaseKernel(kernel)
		}
	}
}
