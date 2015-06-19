import Foundation
import OpenCL

public class Kernel {
	public var kernel: cl_kernel
	
	public init(program: Program, kernelName: String) {
		
		kernel = kernelName.withCString() { cKernelName -> cl_kernel in
			var status: cl_int = CL_SUCCESS
			let sourceKernel = clCreateKernel(
				program.program,
				cKernelName,
				&status)
			
			if status != CL_SUCCESS {
				print("Create kernel error \(status)")
			}
			
			return sourceKernel
		}
	}
	
	public func setArg<T>(position: cl_uint, buffer: Buffer<T>) -> cl_int {
		return clSetKernelArg(kernel, position, sizeof(cl_mem), &(buffer.buffer))
	}
	
	deinit {
		if kernel != nil {
			clReleaseKernel(kernel)
		}
	}
}
