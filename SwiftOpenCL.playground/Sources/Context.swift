import Foundation
import OpenCL

public class Context {
	public let context: cl_context
	public init(devices: [Device]) {
		
		let numDevices = devices.count
		var deviceIds = devices.map {
			$0.deviceId
		}
		
		context = clCreateContext(nil, cl_uint(numDevices), &deviceIds, nil, nil, nil)
	}
	
	deinit {
		clReleaseContext(context)
	}
}
