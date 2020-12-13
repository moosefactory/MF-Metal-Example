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
        
    // The swift model ( CPU side )
    var world: WorldBuffers
    
    var renderedClosure: ((Int)->Void)?
    
    init(frame frameRect: CGRect, world: WorldBuffers) {
        self.world = world
        super.init(frame: frameRect, device: world.device)
        framebufferOnly = false
    }
    
    required init(coder: NSCoder) {
        fatalError()
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
        //self.isPaused = true
        world.calculator.computeFrame(drawable: currentDrawable) {
        
        }
        //self.isPaused = false
        self.renderedClosure?(self.world.frameIndex)
    }
}
