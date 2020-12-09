//
//  ParticlesCalculator.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 09/12/2020.
//

import Foundation
import MoofFoundation

class ParticlesCalculator: MetalCalculator {
    
    enum Errors: String, Error {
        case particlesBufferEmpty
        case attractorsBufferEmpty
        case settingsBufferEmpty
    }
    
    // Swift Model ( CPU )
    var world: WorldBuffers
        
    var needsUpdateEnvironment: Bool = false
    
    var numberOfParticlesPerGroup: Int = 0
    
    // MARK: - Init
    
    public init(world: WorldBuffers) throws {
        
        self.world = world
        try super.init(device: world.device, computeFunctionName: "computeParticlesForces", drawable: nil)
    }
    
    /// Prepare buffers
    
//    func prepareData(frameIndex: Int) throws {
//        world.
//        updateEnvironment(with: frameIndex)
//    }
    
//    func updateEnvironment(with frame: Int) {
//        // Fill settings buffer with the settings
//        // This is done once when calculator is created, or when the user changes some values using UI
//
//        let drawableSize = drawable?.bounds ?? .zero
//
//        settingsArray[0] = Model.Settings(frame: frame.simd,
//                                          width: Int32(drawableSize.width),
//                                          height: Int32(drawableSize.height),
//                                          radius: drawableSize.hypo.simd,
//                                          numberOfAttractors: world.attractors.count.simd,
//                                          // We don't use the groups in particles calculator
//                                          numberOfGroups: 0,
//                                          numberOfParticles: world.particles.count.simd,
//                                          numberOfParticlesPerGroup: numberOfParticlesPerGroup.simd,
//                                          minimaldistance: minimalDistance.simd,
//                                          gravityFactor: gravityFactor.simd,
//                                          gravityExponent: gravityExponent.simd)
//    }
//
    /// Update the attractors metal buffers from the swift model
    ///
    /// We need to update buffers because attractors position is computed on CPU
    
//    func updateData(with drawable: CAMetalDrawable?, frameIndex: Int) {
//        self.drawable = drawable
//        guard let drawable = drawable else { return }
//
//        // Update drawable size in settings
//        world.rendererSize = drawable.bounds.size
//
//    }
    
    /// Encode command
    ///
    /// Render pass descriptor is used for more complex cases ( With vertexes ).
    /// In this example, we don't need it. We simply compute pixels color, and move onscreen at the end
    override func encodeCommand(commandBuffer: MTLCommandBuffer, rpd: MTLRenderPassDescriptor? = nil) throws {
        let nParticles = world.world.particles.count
        guard nParticles > 0 else {
            throw Errors.particlesBufferEmpty
        }
        // Start a compute pass.
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
            throw MetalCalculator.Errors.cantMakeCommandEncoder
        }
        
        computeEncoder.setComputePipelineState(computePipelineState)
        
        // Set the subdivision size
        // We subdivide view in 8 x 8, meaning we will have 256 processing threads
        let cols = 1
        let rows = 1
        let threadsPerThreadgroupSize = MTLSize(width: cols, height: rows, depth: 1)
        
        // We compute thread group size.
        
        // To avoid this missed particles due to int division, we divide in floating point and take the ceiling.
        // It will be up to us to check bounds in calulator, since the gid will possibly be greater than
        // the actual number of particles
        
        
        let particlesPerGroup = Int(ceil(Double(nParticles) / Double(threadsPerThreadgroupSize.width)))
        let numberOfParticleGroups = Int(ceil(Double(nParticles) / Double(particlesPerGroup)))
        
        let threadGroupsSize = MTLSize(width: particlesPerGroup, height: numberOfParticleGroups, depth: 1)
        
        // Set the number of particles per group in our environment structure
        world.settingsArray[0].numberOfParticlesPerGroup = particlesPerGroup.simd
        
        // Pass buffers to GPU
        computeEncoder.setBuffer(world.particlesBuffer, offset: 0, index: 0)
        computeEncoder.setBuffer(world.attractorsBuffer, offset: 0, index: 1)
        computeEncoder.setBuffer(world.settingsBuffer, offset: 0, index: 2)

        // Dispatch threads
        computeEncoder.dispatchThreadgroups(threadGroupsSize, threadsPerThreadgroup: threadsPerThreadgroupSize)
        
        // Send commands to GPU
        computeEncoder.endEncoding()
        
    }
}
