//
//  GravityFieldCalculator.swift
//  Gravitic
//
//  Created by Tristan Leblanc on 22/11/2020.
//  Copyright © 2020 Moose Factory Software. All rights reserved.
//

import Foundation
import MoofFoundation

class GravityFieldsCalculator: MetalCalculator {
    
    enum Errors: String, Error {
        case groupsBufferEmpty
        case attractorsBufferEmpty
        case settingsBufferEmpty
    }
        
    // Swift Model ( CPU )
    
    var world: WorldBuffers
    
    var needsUpdateEnvironment: Bool = false
    
    // MARK: - Init
    
    public init(drawable: CAMetalDrawable,
                world: WorldBuffers) throws {
        
        self.world = world
        try super.init(device: world.device, computeFunctionName: "computeGravityFields", drawable: drawable)
    }
        
    /// Encode command
    ///
    /// Render pass descriptor is used for more complex cases ( With vertexes ).
    /// In this example, we don't need it. We simply compute pixels color, and move onscreen at the end
    override func encodeCommand(commandBuffer: MTLCommandBuffer, rpd: MTLRenderPassDescriptor? = nil) throws {
        if let drawable = drawable,
           let attractorsBuffer = world.attractorsBuffer,
           let settingsBuffer = world.settingsBuffer {
            
            // Start a compute pass.
            guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
                throw MetalCalculator.Errors.cantMakeCommandEncoder
            }
            
            computeEncoder.setComputePipelineState(computeFunctionPipelineState)
            
            let texture = drawable.texture
            
            // Get the drawable size to compute thread groups sizes
            let drawableSize = CGSize(width: texture.width, height: texture.height)
            
            //world.rendererSize = drawableSize
            
            // Pass buffers to GPU
            computeEncoder.setTexture(texture, index: 0)
            computeEncoder.setBuffer(attractorsBuffer, offset: 0, index: 0)
            computeEncoder.setBuffer(settingsBuffer, offset: 0, index: 1)
            
            // Set the subdivision size
            // We subdivide view in 8 x 8, meaning we will have 256 processing threads
            let cols = 16
            let rows = 16
            let threadsPerThreadgroupSize = MTLSize(width: cols, height: rows, depth: 1)
            
            // We compute thread group size ( tile size ).
            // If drawable width or height are not divisible by cols and rows, we will have a margin at right and/or bottom of the view
            // To avoid this missed pixels due to int division, we divide in floating point and take the ceiling.
            
            let tileWidth = Int(ceil(drawableSize.width / CGFloat(threadsPerThreadgroupSize.width)))
            let tileHeight = Int(ceil(drawableSize.height / CGFloat(threadsPerThreadgroupSize.height)))
            
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
