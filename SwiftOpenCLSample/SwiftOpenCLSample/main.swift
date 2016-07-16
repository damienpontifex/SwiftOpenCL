//
//  main.swift
//  SwiftOpenCLSample
//
//  Created by Damien Pontifex on 16/07/2016.
//  Copyright © 2016 Damien Pontifex. All rights reserved.
//

import Foundation
import SwiftOpenCL
import OpenCL

let platforms = Platform.allPlatforms()

guard let thisPlatform = platforms.first else {
	exit(EXIT_FAILURE)
}

let devices = thisPlatform.getDevices(CL_DEVICE_TYPE_CPU)
print("Found \(devices.count) CPU devices")
