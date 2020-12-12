//
//  GraviFieldsRenderView.swift
//  TestMetal
//
//  Created by Tristan Leblanc on 24/11/2020.
//  Copyright © 2020 MooseFactory Software. All rights reserved.
//

import MoofFoundation
import MetalKit

/// A view that renders gravity fields between moving attractors
class GraviFieldsView: MTKView {
        
    // The metal calculator
    var calculator: GravityFieldsCalculator?
    
    // The swift model ( CPU side )
    var world: WorldBuffers

    var renderedClosure: ((Int)->Void)?
        
    init(frame frameRect: CGRect, world: WorldBuffers) {
        self.world = world
        super.init(frame: frameRect, device: world.device)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    func setup() {
        // Authorize the metal function to write in texture memory
        framebufferOnly = false
    }
    
    func makeCalculator(with drawable: CAMetalDrawable) -> GravityFieldsCalculator {
        return try! GravityFieldsCalculator(drawable: drawable, world: world)
    }
    
    #if os(macOS)
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        render()
    }
    #else
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        render()
    }
    #endif
    
    func render() {
        // Check if a drawable is available
        guard let drawable = currentDrawable else {
            return
        }
        
        // If calculator is nil, we create it now
        if calculator == nil {
            calculator = makeCalculator(with: drawable)
        } else {
            if drawable.bounds != calculator!.drawable?.bounds {
                world.updateFlag.insert(.settings)
            }
            // We attach drawable to calculator to process available texture
            calculator!.drawable = drawable
        }
        
        guard let calculator = calculator else { return }

        // Will recreate buffers if updateFlag is set
        world.createOrUpdateBuffers()
        if !world.updateFlag.contains([.attractors]) {
            try? calculator.compute(rpd: currentRenderPassDescriptor) { commandBuffer in
            }
        }
        self.renderedClosure?(self.world.frameIndex)
        self.world.frameIndex += 1
    }
}
