import OpenCL

public struct ClError: ErrorType {
	
	var err: cl_int
	var errString: String?
	
	public init(err: cl_int, errString: String? = nil) {
		self.err = err
		self.errString = errString
	}
	
	static func check(err: cl_int) throws {
		if err != OpenCL.CL_SUCCESS {
			throw ClError(err: err)
		}
	}
}