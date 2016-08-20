import XCTest
import SwiftOpenCL
import OpenCL

class PlatformTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    func testGettingAllPlatforms() {
        // SwiftOpenCL
        let platforms = Platform.all

        // C OpenCL
        var platformCount: cl_uint = 0
		clGetPlatformIDs(0, nil, &platformCount)

        var platformIds = Array<cl_platform_id?>(repeating: nil, count: Int(platformCount))
		
		clGetPlatformIDs(platformCount, &platformIds, nil)

        XCTAssertEqual(platformCount, cl_uint(platforms.count))
    }
}
