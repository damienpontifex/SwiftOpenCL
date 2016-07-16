import OpenCL

public class Program {
	public var program: cl_program
	
	public convenience init(context: Context, programPath: String) throws {
		let programSource = try String(contentsOfFile: programPath, encoding: NSUTF8StringEncoding)
		try self.init(context: context, programSource: programSource)
	}
	
	public init(context: Context, programSource: String) throws {
		
		var status: cl_int = CL_SUCCESS
		program = programSource.withCString() { (cString) -> cl_program in
			var localCString = cString
			return withUnsafeMutablePointer(&localCString) { mutableCString -> cl_program in
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
	
			var length: Int = 0
			clGetProgramBuildInfo(program, device.deviceId, cl_program_build_info(CL_PROGRAM_BUILD_LOG), 0, nil, &length)
			
			var value = Array<CChar>(count: length, repeatedValue: CChar(32))
			clGetProgramBuildInfo(program, device.deviceId, cl_program_build_info(CL_PROGRAM_BUILD_LOG), length, &value, nil)
			
			throw ClError(err: status, errString: String.fromCString(&value))
		}
	}
	
	deinit {
		if program != nil {
			clReleaseProgram(program)
		}
	}
}
