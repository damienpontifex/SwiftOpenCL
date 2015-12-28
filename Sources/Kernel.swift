import OpenCL

public class Kernel {
	public var kernel: cl_kernel
	
	public init(program: Program, kernelName: String) throws {
		
		var status: cl_int = CL_SUCCESS
		
		kernel = kernelName.withCString() { cKernelName -> cl_kernel in
			let sourceKernel = clCreateKernel(
				program.program,
				cKernelName,
				&status)
			
			return sourceKernel
		}
		
		try ClError.check(status)
	}
	
	public func setArg<T>(position: cl_uint, buffer: Buffer<T>) throws {
		let err = clSetKernelArg(kernel, position, sizeof(cl_mem), &(buffer.buffer))
		
		try ClError.check(err)
	}
	
	deinit {
		if kernel != nil {
			clReleaseKernel(kernel)
		}
	}
}
