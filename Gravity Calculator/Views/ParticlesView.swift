//
//  ParticlesView.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 09/12/2020.
//


import MoofFoundation
import QuartzCore

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

#if os(macOS)
class ParticlesView: NSView {
    
    var world: WorldBuffers
    
    var particleCalculator: ParticlesCalculator?
    
    lazy var particlesLayer = {
        ParticlesLayer(world: world)
    }()
    
    init(frame frameRect: NSRect, world: WorldBuffers) {
        self.world = world
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setup() {
        wantsLayer = true
        layer?.addSublayer(particlesLayer)
        particlesLayer.frame = bounds
    }
    
    override var frame: NSRect {
        didSet {
            particlesLayer.frame = bounds
        }
    }
    
    func update() {
        if particleCalculator == nil {
            particleCalculator = try? ParticlesCalculator(world: world)
        }
        try? particleCalculator?.compute(completion: { (commandBuffer) in
            DispatchQueue.main.async {
                self.particlesLayer.update()
            }
        })
    }
}

#else

#endif
