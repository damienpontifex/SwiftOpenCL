import OpenCL

public class Program {
	public var program: cl_program
	
	public convenience init(context: Context, programPath: String) throws {
		let programSource = try String(contentsOfFile: programPath, encoding: NSUTF8StringEncoding)
		try self.init(context: context, programSource: programSource)
	}
	
	public init(context: Context, programSource: String) throws {
		
		var status: cl_int = CL_SUCCESS
		program = programSource.withCString() { (var cString) -> cl_program in
			return withUnsafeMutablePointer(&cString) { mutableCString -> cl_program in
				let sourceProgram = clCreateProgramWithSource(context.context, 1, mutableCString, nil, &status)
				return sourceProgram
			}
		}
		
		try ClError.check(status)
	}
	
	public func build(device: Device) throws {
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
			
			try ClError.check(status)
		}
	}
	
	deinit {
		if program != nil {
			clReleaseProgram(program)
		}
	}
}
