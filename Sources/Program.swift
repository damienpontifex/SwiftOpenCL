import OpenCL

public class Program {
	public var program: cl_program
	
	public init?(context: Context, programSource: String) {
		
		var status: cl_int = CL_SUCCESS
		program = programSource.withCString() { (var cString) -> cl_program in
			return withUnsafeMutablePointer(&cString) { mutableCString -> cl_program in
				let sourceProgram = clCreateProgramWithSource(context.context, 1, mutableCString, nil, &status)
				return sourceProgram
			}
		}
		if status != CL_SUCCESS {
			//			let error = ClError(rawValue: status) ?? ClError.CL_UNKNOWN_ERROR
			print("Create program error \(status)")
			return nil
		}
	}
	
	public func build(device: Device) -> Bool {
		let status = clBuildProgram(program,
			1,
			&device.deviceId,
			nil,
			nil,
			nil)
		
		if status != CL_SUCCESS {
			print("Build program error \(status)")
	
			var length: Int = 0
			clGetProgramBuildInfo(program, device.deviceId, cl_program_build_info(CL_PROGRAM_BUILD_LOG), 0, nil, &length)
			
			var value = Array<CChar>(count: length, repeatedValue: CChar(32))
			clGetProgramBuildInfo(program, device.deviceId, cl_program_build_info(CL_PROGRAM_BUILD_LOG), length, &value, nil)
			
			print("CLProgram build log \(String.fromCString(&value))")
			
			return false
		}
		
		return true
	}
	
	deinit {
		if program != nil {
			clReleaseProgram(program)
		}
	}
}
