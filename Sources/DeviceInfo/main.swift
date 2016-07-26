import Foundation
import SwiftOpenCL
import OpenCL

for platform in Platform.all {
    for device in platform.getDevices(.all) {
        print("Using device \(device)")

        if let version = device.getStringInfo(CL_DEVICE_VERSION) {
            print("Hardware version: \(version)")
        }
        if let driverVersion = device.getStringInfo(CL_DRIVER_VERSION) {
            print("Software version: \(driverVersion)")
        }
        if let cVersion = device.getStringInfo(CL_DEVICE_OPENCL_C_VERSION) {
            print("OpenCL C version: \(cVersion)")
        }
        if let maxComputeUnits: [cl_uint] = device.getInfo(CL_DEVICE_MAX_COMPUTE_UNITS) {
            print("Parallel compute units: \(maxComputeUnits)")
        }
    }
}