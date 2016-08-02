import OpenCL

public struct ClError: Error {
	
	public var err: cl_int
	public var errString: String?
	
	public init(err: cl_int, errString: String? = nil) {
		self.err = err
		self.errString = errString
	}
	
	static func check(_ err: cl_int) throws {
		if err != OpenCL.CL_SUCCESS {
			throw ClError(err: err)
		}
	}
}
