//
//  World+GPU.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 09/12/2020.
//

import MoofFoundation
import Combine

class WorldBuffers {
    
    /// This holds a copy of the world objects, so we can use any object in computation
    /// even when the user does some changes in the UI
    private var objects: World.Objects { return world.objects }
    
    /// Update flag change will be published by World object and stored locally.
    private(set) var world: World

    var updateFlag: World.UpdateFlag {
        get { return world.updateFlag }
        set { world.updateFlag = newValue }
    }
    
    // Aggregate Calculator
    
    var calculator: AggregateCalculator!
    
    // MTL Buffers
    
    private(set) var particlesBuffer: MTLBuffer!
    private(set) var groupsBuffer: MTLBuffer!
    private(set) var attractorsBuffer: MTLBuffer!
    private(set) var settingsBuffer: MTLBuffer!
    
    var numberOfAttractorsGroups: Int = 0
    var numberOfAttractors: Int = 0
    var numberOfParticles: Int = 0
    
    private(set) var device: MTLDevice
    
    // Rendering
    var frameIndex: Int = 0 {
        didSet {
            settingsArray[0].frame = frameIndex.simd
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
    
    var particlesBufferSize: Int { return objects.particles.count * MemoryLayout<Model.Particle>.stride }
    
    var particlesArray: UnsafeMutablePointer<Model.Particle> {
        particlesBuffer.contents().assumingMemoryBound(to: Model.Particle.self)
    }

    var attractorsBufferSize: Int { return objects.attractors.count * MemoryLayout<Model.Attractor>.stride }
    
    var attractorsArray: UnsafeMutablePointer<Model.Attractor> {
        attractorsBuffer.contents().assumingMemoryBound(to: Model.Attractor.self)
    }
    
    var groupsBufferSize: Int { return objects.groups.count * MemoryLayout<Model.Group>.stride }
    
    var groupsArray: UnsafeMutablePointer<Model.Group> {
        groupsBuffer.contents().assumingMemoryBound(to: Model.Group.self)
    }
    
    var settingsBufferSize: Int { return MemoryLayout<Model.Environment>.stride }
    
    var settingsArray: UnsafeMutablePointer<Model.Environment> {
        settingsBuffer.contents().assumingMemoryBound(to: Model.Environment.self)
    }

    var commandQueue: MTLCommandQueue
    
    // MARK: -  Initialisation
    
    init(world: World, for device: MTLDevice) throws {
        self.device = device
        self.commandQueue = try device.safeMakeCommandQueue()
        self.world = world
        self.calculator = AggregateCalculator(world: self)
    }
    
    // Create buffers. This function will be called on creation and or when number of elements is changed
    //
    // Returns true if buffer were recreated.
    
    func createOrUpdateBuffers() -> Bool {
        
        var out = false
        
        //guard !updateFlag.isEmpty else { return }

        // We create settings only once, since its size will never change
        
        if settingsBuffer == nil {
            settingsBuffer = device.tryToMakeBuffer(length: settingsBufferSize)
        }
        
        updateEnvironment()
        

        // Attractors changed
        
       if updateFlag.contains(.attractors) {
            groupsBuffer = device.tryToMakeBuffer(length: groupsBufferSize)
            attractorsBuffer = device.tryToMakeBuffer(length: attractorsBufferSize)

            objects.attractors.enumerated().forEach { index, attractor in
                attractorsArray[index] = attractor
            }

            objects.groups.enumerated().forEach { index, group in
                groupsArray[index] = group
            }
            
            // Store attractors buffer size for access from outside
            // (world objects count may differ from buffer size)
            numberOfAttractors = world.objects.attractors.count
            numberOfAttractorsGroups = world.objects.groups.count
            out = true
       }
        
        // Particles changed
        
        if updateFlag.contains(.particles) {
            particlesBuffer = device.tryToMakeBuffer(length: particlesBufferSize)
            objects.particles.enumerated().forEach { index, particle in
                particlesArray[index] = particle
            }            
            numberOfParticles = world.objects.particles.count
            out = true
        }
        
        return out
    }
    
    //MARK: - Buffer updates
    
    /// We add renderer properties to World settings
    func updateEnvironment() {
        settingsArray[0] = Model.Environment(frame: frameIndex.simd,
                                          width: Int32(rendererSize.width),
                                          height: Int32(rendererSize.height),
                                          radius: rendererSize.diagonal.simd,
                                          numberOfAttractors: objects.attractors.count.simd,
                                          numberOfGroups: objects.groups.count.simd,
                                          numberOfParticles: objects.particles.count.simd,
                                          numberOfParticlesPerThreadGroup: 0,
                                          numberOfAttractorsPerThreadGroup: 0,
                                          minimalDistance: objects.settings.minimalDistance,
                                          gravityFactor: objects.settings.gravityFactor,
                                          gravityExponent: objects.settings.gravityExponent,
                                          
                                          scale: objects.settings.scale,
                                          fieldsSensitivity: objects.settings.fieldsSensitivity,
                                          invertColors: objects.settings.invertColors,

                                          lockParticles: objects.settings.lockParticles,
                                          spring: objects.settings.spring)

    }
}
