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
        
    func update() {
        guard !isHidden && !particlesLayer.updating else { return }
        // We avoid accessing buffer while recreating particles
        if !world.updateFlag.contains(.particles) {
            self.particlesLayer.update()
        }
    }
}
