//
//  AttractorGroupsCalculator+CPU.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 13/12/2020.
//


import MoofFoundation

class AttractorsGroupsCalculator: WorldCalculator {
                    
    init(world: WorldBuffers) throws {
        try super.init(world: world, functionName: "computeAttractorsGroupsLocations")
    }
    
    /// Encode command
    ///
    /// Render pass descriptor is used for more complex cases ( With vertexes ).
    /// In this example, we don't need it. We simply compute pixels color, and move onscreen at the end
    override func encodeCommand(commandBuffer: MTLCommandBuffer, rpd: MTLRenderPassDescriptor? = nil) throws {
        
        let nGroups = world.numberOfAttractorsGroups
        guard nGroups > 0 else {
            throw Errors.attractorsGroupsBufferEmpty
        }
        
        // Start a compute pass.
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
            throw MetalCalculator.Errors.cantMakeCommandEncoder
        }
        
        computeEncoder.setComputePipelineState(computeFunctionPipelineState)
        
        // Set the subdivision size - we use one thread, because we need to compute all attractors
        // in sequential order.
        let threadsPerThreadgroupSize = MTLSize(width: 1, height: 1, depth: 1)
        
        // We compute thread group size.
        let threadGroupsSize = MTLSize(width: 1, height: 1, depth: 1)
                
        // Pass buffers to GPU
        computeEncoder.setBuffer(world.groupsBuffer, offset: 0, index: 0)
        computeEncoder.setBuffer(world.settingsBuffer, offset: 0, index: 1)

        // Dispatch threads
        computeEncoder.dispatchThreadgroups(threadGroupsSize, threadsPerThreadgroup: threadsPerThreadgroupSize)
        
        // Send commands to GPU
        computeEncoder.endEncoding()
    }
}
