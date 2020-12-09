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
        framebufferOnly = false
        #if os(macOS)
        layer?.backgroundColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        layer?.isOpaque = false
        #else
        layer.backgroundColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        layer.isOpaque = false
        #endif
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
        guard let drawable = currentDrawable else {
            return
        }
        // If calculator is nil, we recreate buffers
        // Calulator can be set nil when attractors are recreated or size is changed
        if calculator == nil {
            calculator = makeCalculator(with: drawable)
        } else {
            calculator?.drawable = drawable
            
            self.renderedClosure?(self.world.frameIndex)
            DispatchQueue.main.async {
                self.world.world.recreateBuffersIfNeeded()
                if self.world.needsRecreateBuffer {
                    self.world.createBuffers()
                }
            }

            self.world.frameIndex += 1
        }
        try? calculator!.compute(rpd: currentRenderPassDescriptor) { commandBuffer in
            
        }
    }
}
