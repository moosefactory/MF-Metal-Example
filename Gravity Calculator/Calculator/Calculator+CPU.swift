//
//  GravityFieldCalculator.swift
//  Gravitic
//
//  Created by Tristan Leblanc on 22/11/2020.
//  Copyright © 2020 Moose Factory Software. All rights reserved.
//

import Foundation
import MoofFoundation

class Calculator: MetalCalculator {
    
    enum Errors: String, Error {
        case groupsBufferEmpty
        case attractorsBufferEmpty
        case settingsBufferEmpty
    }
    
    var groupsBuffer: MTLBuffer!
    var attractorsBuffer: MTLBuffer!
    var settingsBuffer: MTLBuffer!
    
    // Swift Model ( CPU )
    
    var attractors: [Model.Attractor]
    var groups: [Model.Group]
    
    var numberOfAttractors: Int { attractors.count }
    var numberOfGroups: Int { groups.count }
    
    // Settings
    var gravityFactor: CGFloat = 1 { didSet { needsUpdateEnvironment = true }}
    var gravityExponent: CGFloat = 2 { didSet { needsUpdateEnvironment = true }}
    var minimalDistance: CGFloat = 1 { didSet { needsUpdateEnvironment = true }}
    
    var needsUpdateEnvironment: Bool = false
    
    // MARK: - Init
    
    public init(device: MTLDevice = MTLCreateSystemDefaultDevice()!,
                drawable: CAMetalDrawable,
                groups: [Model.Group],
                attractors: [Model.Attractor]) throws {
        
        self.groups = groups
        self.attractors = attractors
        try super.init(device: device, computeFunctionName: "computeGravityFields", drawable: drawable)
    }
    
    // MARK: - Convenience Buffer accessors
    
    var attractorsBufferSize: Int { return numberOfAttractors * MemoryLayout<Model.Attractor>.stride }
    
    var attractorsArray: UnsafeMutablePointer<Model.Attractor> {
        attractorsBuffer.contents().assumingMemoryBound(to: Model.Attractor.self)
    }
    
    var groupsBufferSize: Int { return numberOfGroups * MemoryLayout<Model.Group>.stride }
    
    var groupsArray: UnsafeMutablePointer<Model.Group> {
        groupsBuffer.contents().assumingMemoryBound(to: Model.Group.self)
    }
    
    var settingsBufferSize: Int { return MemoryLayout<Model.Settings>.stride }
    
    var settingsArray: UnsafeMutablePointer<Model.Settings> {
        settingsBuffer.contents().assumingMemoryBound(to: Model.Settings.self)
    }
    
    /// Prepare buffers
    
    func prepareData(frameIndex: Int) throws {
        
        // Creates groups buffer
        guard groupsBufferSize > 0 else { throw Errors.groupsBufferEmpty }
        groupsBuffer = device.makeBuffer(length: groupsBufferSize, options: MTLResourceOptions.storageModeShared)
        
        // Creates attractors buffer
        guard attractorsBufferSize > 0 else { throw Errors.attractorsBufferEmpty }
        attractorsBuffer = device.makeBuffer(length: attractorsBufferSize, options: MTLResourceOptions.storageModeShared)
        
        // Creates settings buffer
        guard settingsBufferSize > 0 else { throw Errors.settingsBufferEmpty }
        settingsBuffer = device.makeBuffer(length: settingsBufferSize, options: MTLResourceOptions.storageModeShared)
        
        // Create groups buffer
        // This is done once when calculator is created - groups won't change during animation
        groups.enumerated().forEach { index, group in
            groupsArray[index] = group
        }
        
        updateEnvironment(with: frameIndex)
    }
    
    func updateEnvironment(with frame: Int) {
        // Fill settings buffer with the settings
        // This is done once when calculator is created, or when the user changes some values using UI
        
        let drawableSize = drawable?.bounds ?? .zero
        
        settingsArray[0] = Model.Settings(frame: frame.simd,
                                          width: Int32(drawableSize.width),
                                          height: Int32(drawableSize.height),
                                          radius: drawableSize.hypo.simd,
                                          numberOfAttractors: attractors.count.simd,
                                          numberOfGroups: groups.count.simd,
                                          minimaldistance: minimalDistance.simd,
                                          gravityFactor: gravityFactor.simd,
                                          gravityExponent: gravityExponent.simd)
    }
    
    /// Update the attractors metal buffers from the swift model
    ///
    /// We need to update buffers because attractors position is computed on CPU
    
    func updateData(with drawable: CAMetalDrawable?, frameIndex: Int) {
        self.drawable = drawable
        guard let drawable = drawable else { return }
        
        /// Create attractors buffer from the swift model attractors
        /// We pass the frame index to compute position
        attractors.enumerated().forEach { index, attractor in
            attractorsArray[index] = attractor.positionned(at: frameIndex, in: drawable.bounds, in: groups)
        }
        
        if needsUpdateEnvironment {
            updateEnvironment(with: frameIndex)
            needsUpdateEnvironment = false
        }
    }
    
    /// Encode command
    ///
    /// Render pass descriptor is used for more complex cases ( With vertexes ).
    /// In this example, we don't need it. We simply compute pixels color, and move onscreen at the end
    override func encodeCommand(commandBuffer: MTLCommandBuffer, rpd: MTLRenderPassDescriptor? = nil) throws {
        if let drawable = drawable {
            
            // Start a compute pass.
            guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
                throw MetalCalculator.Errors.cantMakeCommandEncoder
            }
            
            computeEncoder.setComputePipelineState(computePipelineState)
            
            
            let texture = drawable.texture
            
            // Get the drawable size to compute thread groups sizes
            let drawableSize = (w: texture.width, h: texture.height)
            
            // Pass buffers to GPU
            computeEncoder.setTexture(texture, index: 0)
            computeEncoder.setBuffer(groupsBuffer, offset: 0, index: 0)
            computeEncoder.setBuffer(attractorsBuffer, offset: 0, index: 1)
            computeEncoder.setBuffer(settingsBuffer, offset: 0, index: 2)
            
            // Set the subdivision size
            // We subdivide view in 8 x 8, meaning we will have 256 processing threads
            let cols = 16
            let rows = 16
            let threadsPerThreadgroupSize = MTLSize(width: cols, height: rows, depth: 1)
            
            // We compute thread group size ( tile size ).
            // If drawable width or height are not divisible by cols and rows, we will have a margin at right and/or bottom of the view
            // To avoid this missed pixels due to int division, we divide in floating point and take the ceiling.
            
            let tileWidth = Int(ceil(Double(drawableSize.w) / Double(threadsPerThreadgroupSize.width)))
            let tileHeight = Int(ceil(Double(drawableSize.h) / Double(threadsPerThreadgroupSize.height)))
            
            let threadGroupsSize = MTLSize(width: tileWidth, height: tileHeight, depth: 1)
            
            // Dispatch threads
            computeEncoder.dispatchThreadgroups(threadGroupsSize, threadsPerThreadgroup: threadsPerThreadgroupSize)
            
            // Send commands to GPU
            computeEncoder.endEncoding()
            
            // Display computed texture into drawable ( Metal view )
            commandBuffer.present(drawable)
        }
    }
}
