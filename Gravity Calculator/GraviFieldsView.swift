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
    
    // The frame counter, used to determine attractors and groups angle
    var frameIndex = 0
    
    // The metal calculator
    var calculator: Calculator?
    
    // The swift model ( CPU side )
    var attractors = [Model.Attractor]()
    var groups = [Model.Group.root]

    var renderedClosure: ((Int)->Void)?
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
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
    
    func makeCalculator(with drawable: CAMetalDrawable) -> Calculator {
        if attractors.isEmpty {
           makeWorld()
        }
        let calc = try! Calculator(drawable: drawable,
                                               groups: groups,
                                               attractors: attractors)
        try! calc.prepareData(frameIndex: frameIndex)
        return calc
    }
    
    #if os(macOS)
    override func draw(_ dirtyRect: NSRect) {
        render()
    }
    #else
    override func draw(_ rect: CGRect) {
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
        }
        // Update data will update necessary buffers
        calculator?.updateData(with: drawable,frameIndex: frameIndex)
        try? calculator!.compute(rpd: currentRenderPassDescriptor) { commandBuffer in

        }
        
        renderedClosure?(frameIndex)
        frameIndex += 1
        
    }
}
