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
		
		var platformIds = Array<cl_platform_id?>(repeating: nil, count: Int(platformCount))
		
		clGetPlatformIDs(platformCount, &platformIds, nil)
		
		let platforms: [Platform] = platformIds.flatMap {
			guard let platformId = $0 else {
				return nil
			}
			return Platform(id: platformId)
		}
		
		return platforms
	}
	
	public func getInfo(_ info: cl_platform_info) -> String? {
		
		var infoSize: Int = 0
		clGetPlatformInfo(platformId, info, 0, nil, &infoSize)
		
		var infoArray = Array<CChar>(repeating: CChar(32), count: infoSize)
		clGetPlatformInfo(platformId, info, infoSize, &infoArray, nil)
		
		let infoString = String(cString: &infoArray)
		return infoString
	}
	
	public func getDevices(_ deviceType: DeviceType = .gpu) -> [Device] {
		
		var deviceCount: cl_uint = 0
		clGetDeviceIDs(platformId, cl_device_type(deviceType.nativeType), 0, nil, &deviceCount)
		
		var deviceIds = Array<cl_device_id?>(repeating: nil, count: Int(deviceCount))
		
		clGetDeviceIDs(platformId, cl_device_type(deviceType.nativeType), deviceCount, &deviceIds, nil)
		
		let devices: [Device] = deviceIds.flatMap {
			guard let deviceId = $0 else {
				return nil
			}
			return Device(id: deviceId)
		}
		
		return devices
	}
}
