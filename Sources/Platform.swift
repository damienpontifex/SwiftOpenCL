import OpenCL

public class Platform : CustomStringConvertible {
	public var platformId: cl_platform_id
	public init(id: cl_platform_id) {
		platformId = id
	}
	
	public var description: String {
		let version = getInfo(cl_platform_info(CL_PLATFORM_VERSION)) ?? "Unknown Version"
		let name = getInfo(cl_platform_info(CL_PLATFORM_NAME)) ?? "No Platform"
		return name + " Platform running " + version
	}
	
	public class func allPlatforms() -> [Platform] {
		var platformCount: cl_uint = 0
		clGetPlatformIDs(0, nil, &platformCount)
		
		var platformIds = Array<cl_platform_id>(count: Int(platformCount), repeatedValue: cl_platform_id())
		
		clGetPlatformIDs(platformCount, &platformIds, nil)
		
		let platforms = platformIds.map {
			Platform(id: $0)
		}
		
		return platforms
	}
	
	public func getInfo(info: cl_platform_info) -> String? {
		
		var infoSize: Int = 0
		clGetPlatformInfo(platformId, info, 0, nil, &infoSize)
		
		var infoArray = Array<CChar>(count: infoSize, repeatedValue: CChar(32))
		clGetPlatformInfo(platformId, info, infoSize, &infoArray, nil)
		
		let infoString = String.fromCString(&infoArray)
		return infoString
	}
	
	public func getDevices(deviceType: Int32) -> [Device] {
		
		var deviceCount: cl_uint = 0
		clGetDeviceIDs(platformId, cl_device_type(deviceType), 0, nil, &deviceCount)
		
		var deviceIds = Array<cl_device_id>(count: Int(deviceCount), repeatedValue: cl_device_id())
		
		clGetDeviceIDs(platformId, cl_device_type(deviceType), deviceCount, &deviceIds, nil)
		
		let devices = deviceIds.map {
			Device(id: $0)
		}
		
		return devices
	}
}
