//
//  World+GPU.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 09/12/2020.
//

import MoofFoundation
import Metal


class WorldBuffers {
    var particlesBuffer: MTLBuffer!
    var groupsBuffer: MTLBuffer!
    var attractorsBuffer: MTLBuffer!
    var settingsBuffer: MTLBuffer!
    
    var device: MTLDevice
    var world: World
    
    var needsRecreateBuffer: Bool = false
    
    // Rendering
    var frameIndex: Int = 0 {
        didSet {
            settingsArray[0].frame = frameIndex.simd
            computeAttractorsPosition()
        }
    }
    
    var rendererSize: CGSize = .zero {
        didSet {
            settingsArray[0].width = Int(rendererSize.width).simd
            settingsArray[0].height = Int(rendererSize.height).simd
            settingsArray[0].radius = rendererSize.diagonal.simd
        }
    }
    
    // MARK: - Convenience Buffer accessors
    
    var particlesBufferSize: Int { return world.particles.count * MemoryLayout<Model.Particle>.stride }
    
    var particlesArray: UnsafeMutablePointer<Model.Particle> {
        particlesBuffer.contents().assumingMemoryBound(to: Model.Particle.self)
    }

    var attractorsBufferSize: Int { return world.attractors.count * MemoryLayout<Model.Attractor>.stride }
    
    var attractorsArray: UnsafeMutablePointer<Model.Attractor> {
        attractorsBuffer.contents().assumingMemoryBound(to: Model.Attractor.self)
    }
    
    var groupsBufferSize: Int { return world.groups.count * MemoryLayout<Model.Group>.stride }
    
    var groupsArray: UnsafeMutablePointer<Model.Group> {
        groupsBuffer.contents().assumingMemoryBound(to: Model.Group.self)
    }
    
    var settingsBufferSize: Int { return MemoryLayout<Model.Settings>.stride }
    
    var settingsArray: UnsafeMutablePointer<Model.Settings> {
        settingsBuffer.contents().assumingMemoryBound(to: Model.Settings.self)
    }

    // MARK: -  Initialisation
    
    init(world: World, for device: MTLDevice) {
        self.world = world
        self.device = device
        createBuffers()
        world.worldChangedClosure = {
            self.needsRecreateBuffer = true
        }
    }
    
    // Create buffers. This function will be called on creation and or when number of elements is changed
    func createBuffers() {
        groupsBuffer = device.tryToMakeBuffer(length: groupsBufferSize)

        attractorsBuffer = device.tryToMakeBuffer(length: attractorsBufferSize)
        
        particlesBuffer = device.tryToMakeBuffer(length: particlesBufferSize)

        settingsBuffer = device.tryToMakeBuffer(length: settingsBufferSize)
        
        // Fill buffers
        
        world.attractors.enumerated().forEach { index, attractor in
            attractorsArray[index] = attractor
        }

        world.groups.enumerated().forEach { index, group in
            groupsArray[index] = group
        }

        world.particles.enumerated().forEach { index, particle in
            particlesArray[index] = particle
        }
        
        computeAttractorsPosition()
        computeParticlesPosition()
        
        updateEnvironment()
        
        needsRecreateBuffer = false
    }
    
    //MARK: - Buffer updates
    
    func updateEnvironment() {
        settingsArray[0] = Model.Settings(frame: frameIndex.simd,
                                          width: Int32(rendererSize.width),
                                          height: Int32(rendererSize.height),
                                          radius: rendererSize.diagonal.simd,
                                          numberOfAttractors: world.attractors.count.simd,
                                          numberOfGroups: world.groups.count.simd,
                                          numberOfParticles: world.particles.count.simd,
                                          numberOfParticlesPerGroup: 0,
                                          minimalDistance: world.settings.minimalDistance,
                                          gravityFactor: world.settings.gravityFactor,
                                          gravityExponent: world.settings.gravityExponent)

    }
    
    func computeAttractorsPosition() {
        let rendererFrame = CGRect(origin: .zero, size: rendererSize)
        world.attractors.enumerated().forEach { (index, attractor) in
            attractorsArray[index] = attractor.positionned(at: frameIndex, in: rendererFrame, in: world.groups)
        }
    }
    
    func computeParticlesPosition() {
        let rendererFrame = CGRect(origin: .zero, size: rendererSize)
        world.particles.enumerated().forEach { (index, particle) in
            let newParticle = Model.Particle(location: CGPoint(simd: particle.location).fromPositiveFractional(in: rendererFrame).simd,
                                             mass: particle.mass,
                                             color: particle.color,
                                             gravityVector: particle.gravityVector,
                                             gravityPolarVector: particle.gravityPolarVector)
            
            particlesArray[index] = newParticle
        }
    }

}
