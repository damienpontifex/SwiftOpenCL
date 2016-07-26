//
//  main.swift
//  SimpleKernel
//
//  Created by Damien Pontifex on 26/07/2016.
//  Copyright © 2016 Pontifex. All rights reserved.
//

import Foundation
import SwiftOpenCL
import OpenCL

guard let device = Device.default() else {
	exit(EXIT_FAILURE)
}

do {
	print("Using device \(device)")
	let context = try Context(device: device)
	
	let aInput: [cl_float] = [1, 2, 3, 4]
	let bInput: [cl_float] = [5, 6, 7, 8]
	
	let a = try Buffer<cl_float>(context: context, readOnlyData: aInput)
	let b = try Buffer<cl_float>(context: context, readOnlyData: bInput)
	let c = try Buffer<cl_float>(context: context, count: 4)
	
	let source =
	"__kernel void add(__global const float *a," +
	"                  __global const float *b," +
	"                  __global float *c)" +
	"{" +
	"    const uint i = get_global_id(0);" +
	"    c[i] = a[i] + b[i];" +
	"}";
	
	let program = try Program(context: context, programSource: source)
	try program.build(device)
	
	let kernel = try Kernel(program: program, kernelName: "add")
	
	try kernel.setArgs(a, b, c)
	
	let queue = try CommandQueue(context: context, device: device)
	
	let range = NDRange(size: 4)
	try queue.enqueueNDRangeKernel(kernel, offset: NDRange(size: 0), global: range)
	
	let cResult = c.enqueueRead(queue)
	
	print("a: \(aInput)")
	print("b: \(bInput)")
	print("c: \(cResult)")
	
} catch let error as ClError {
	print("Error \(error.err). \(error.errString)")
}
