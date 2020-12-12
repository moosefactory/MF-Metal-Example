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
typealias View = NSView
typealias Rect = NSRect
#else
import UIKit
typealias View = UIView
typealias Rect = CGRect
#endif

class ParticlesView: View {
    
    var world: WorldBuffers
    
    var particleCalculator: ParticlesCalculator?
        
    lazy var particlesLayer = {
        ParticlesLayer(world: world)
    }()
    
    init(frame frameRect: Rect, world: WorldBuffers) {
        self.world = world
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setup() {
        #if os(macOS)
        wantsLayer = true
        layer?.addSublayer(particlesLayer)
        #else
        layer.addSublayer(particlesLayer)
        #endif
        particlesLayer.frame = bounds
    }
    
    override var frame: Rect {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            particlesLayer.frame = bounds
            CATransaction.commit()
        }
    }
    
    var updating: Bool = false
    
    func update(_ completion: @escaping ()->Void) {
        guard !isHidden && !particlesLayer.updating else { return }

        // Create the matal calculator if needed
        if particleCalculator == nil {
            particleCalculator = try? ParticlesCalculator(world: world)
        }
        
        // If we have no particles, we don't need to compute anything
        // So we simply update with attractors
        guard world.numberOfParticles > 0, particlesLayer.showParticles else {
            self.particlesLayer.update()
            completion()
            return
        }
        
        // We avoid accessing buffer while recreating particles
        if !world.updateFlag.contains(.particles) {
            // Compute particles forces and update layers when done
            try? particleCalculator?.compute(completion: { (commandBuffer) in
                DispatchQueue.main.async {
                    self.particlesLayer.update()
                }
            })
        }
        
        completion()
    }
}
