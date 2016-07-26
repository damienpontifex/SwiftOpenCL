//
//  NDRange.swift
//  SwiftOpenCL
//
//  Created by Damien Pontifex on 28/12/2015.
//  Copyright © 2015 Pontifex. All rights reserved.
//

import OpenCL

public struct NDRange {
	
	var sizes: [size_t] = Array<size_t>(repeating: size_t(0), count: 3)
	let dimensions: cl_uint
	
	public init(size: size_t) {
		dimensions = 1
		sizes[0] = size
	}
	
	public init(size0: size_t, size1: size_t) {
		dimensions = 2
		sizes[0] = size0
		sizes[1] = size1
	}
	
	public init(size0: size_t, size1: size_t, size2: size_t) {
		dimensions = 2
		sizes[0] = size0
		sizes[1] = size1
		sizes[2] = size2
	}
}
