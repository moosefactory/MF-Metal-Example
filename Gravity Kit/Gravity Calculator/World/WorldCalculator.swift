//
//  WorldCalculator.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 13/12/2020.
//

import MoofFoundation

/// A calculator that is created from a World object.
///
/// Calculator will use world command queue and device

class WorldCalculator: MetalCalculator {
    enum Errors: String, Error {
        case particlesBufferEmpty
        case attractorsBufferEmpty
        case attractorsGroupsBufferEmpty
        case settingsBufferEmpty
    }
    
    // Swift Model ( CPU )
    var world: WorldBuffers
    
    // MARK: - Init
    
    public init(world: WorldBuffers, functionName: String) throws {
        self.world = world
        try super.init(device: world.device,
                       queue: world.commandQueue,
                       computeFunctionName: functionName, drawable: nil)
    }
}


/// The aggregate calculator groups all needed calculators.
///
/// The only function of this class is the computeFrame() function.
///
/// It allocates the required calculators on demand and process data in cascade
///
/// It is reference by the world object, so we set world as weak.

class AggregateCalculator {
    
    weak var world: WorldBuffers?
    
    // The metal calculators
    
    var attractorsGroupsCalculators: AttractorsGroupsCalculator!
    var attractorsCalculators: AttractorsCalculator!
    var particleCalculators: ParticlesCalculator!
    var fieldsTextureCalculator: GravityFieldsCalculator!
    
    init(world: WorldBuffers) {
        self.world = world
    }
    
    func computeFrame(drawable: CAMetalDrawable? = nil,
                      renderSize: CGSize? = nil,
                      rpd: MTLRenderPassDescriptor? = nil,
                      buffersCompletion: @escaping ()->Void) {
        
        guard let world = world else {
            return
        }
        
        // We set the render size to either the drawable size if any, or the view size
        guard let renderSize = drawable?.bounds.size ?? renderSize else {
            return
        }
        
        if attractorsGroupsCalculators == nil {
            try? attractorsGroupsCalculators = AttractorsGroupsCalculator(world: world)
        }
        
        if attractorsCalculators == nil {
            try? attractorsCalculators = AttractorsCalculator(world: world)
        }
        
        if particleCalculators == nil  {
            try? particleCalculators = ParticlesCalculator(world: world)
        }
        
        // If we don't hve drawable, we can dispose of the field calculator
        if drawable == nil {
            fieldsTextureCalculator = nil
        } else {
            if fieldsTextureCalculator == nil
                || self.fieldsTextureCalculator?.drawable?.bounds != drawable!.bounds {
                try? fieldsTextureCalculator = GravityFieldsCalculator(drawable: drawable!, world: world)
            }
        }
        
        // Will recreate buffers if updateFlag is set
        world.createOrUpdateBuffers()
        buffersCompletion()
        
        world.rendererSize = renderSize
        
        self.fieldsTextureCalculator?.drawable = drawable
        
        do {

        try self.attractorsGroupsCalculators.compute { mtlCommandBuffer in }
        
        try self.attractorsCalculators.compute { mtlCommandBuffer in }
        
            if world.numberOfParticles > 0 {
            try self.particleCalculators.compute { mtlCommandBuffer in }
        }
            
        try self.fieldsTextureCalculator?.compute(rpd: rpd) { commandBuffer in }
        
        } catch {
            print(error)
        }

        self.world?.updateFlag = []
        self.world?.frameIndex += 1
    }
}
