/*--------------------------------------------------------------------------*/
/*   /\/\/\__/\/\/\        MooseFactory Foundation - v2.0                   */
/*   \/\/\/..\/\/\/                                                         */
/*        |  |             (c)2007-2020 Tristan Leblanc                     */
/*        (oo)             tristan@moosefactory.eu                          */
/* MooseFactory Software                                                    */
/*--------------------------------------------------------------------------*/
/*
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE. */
/*--------------------------------------------------------------------------*/

//  MetalCalculator.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 23/11/2020.

#if !os(watchOS)

import Foundation
import MetalKit
import simd

open class MetalCalculator {
    
    public enum Errors: String, Error {
        case cantMakeCommandBuffer
        case cantMakeCommandEncoder
        case cantFindDefaultLibrary
        case cantMakeComputeFunction
        case cantMakeCommandQueue
    }
    
    public private(set) var device: MTLDevice
    public private(set) var computeFunctionPipelineState: MTLComputePipelineState!
    
    public private(set)var commandQueue: MTLCommandQueue!
    
    var computeFunctionName: String?
    
    public private(set) var defaultLibrary: MTLLibrary!
    
    /// Optional drawable
    ///
    /// If the calculator is used to render an image, attach a drawable
    public  var drawable: CAMetalDrawable?
    
    public init(device: MTLDevice = MTLCreateSystemDefaultDevice()!,
              computeFunctionName: String,
              drawable: CAMetalDrawable? = nil) throws {
        
        self.drawable = drawable
        self.device = device
        
        self.computeFunctionName = computeFunctionName
        
        // Load the shader files with a .metal file extension in the project
        
        guard let defaultLibrary = device.makeDefaultLibrary() else {
            throw Errors.cantFindDefaultLibrary
        }
        
        self.defaultLibrary = defaultLibrary
        
        guard let stateFunction = defaultLibrary.makeFunction(name: computeFunctionName) else {
            throw Errors.cantMakeComputeFunction
        }
        
        // Create a compute pipeline state object.
        
        try computeFunctionPipelineState = device.makeComputePipelineState(function: stateFunction)
        
        guard let commandQueue = device.makeCommandQueue() else {
            throw Errors.cantMakeCommandQueue
        }
        self.commandQueue = commandQueue
    }
    
    public func compute(rpd: MTLRenderPassDescriptor? = nil, completion: @escaping (MTLCommandBuffer)->Void) throws {
        
        // Create a command buffer to hold commands.
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            throw Errors.cantMakeCommandBuffer
        }
        
        // ------->
        // Override in your subclass to add  command sequence
        
        try encodeCommand(commandBuffer: commandBuffer, rpd: rpd)

        // <-------
        
        commandBuffer.addCompletedHandler { (commandBuffer) in
            completion(commandBuffer)
        }
        
        commandBuffer.commit()
    }
    
//    public func makeComputeCommandBuffer() {
//
//    }
    
    open func encodeCommand(commandBuffer: MTLCommandBuffer, rpd: MTLRenderPassDescriptor? = nil) throws { }
}


public extension MTLDevice {
    func tryToMakeBuffer(length: Int, options: MTLResourceOptions = .storageModeShared) -> MTLBuffer? {
        guard length > 0 else { return nil }
        return makeBuffer(length: length, options: options)
    }
}

public extension CAMetalDrawable {

    var bounds: CGRect { return CGRect(x: 0, y: 0, width: self.texture.width, height: self.texture.height) }

}

#endif
