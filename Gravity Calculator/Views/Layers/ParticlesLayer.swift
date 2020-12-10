//
//  ParticlesLayer.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 09/12/2020.
//

import MoofFoundation
//import Quartz

class ParticlesLayer: CALayer {
    
    var world: WorldBuffers
    
    // We set updating to true on update, and to false when done.
    // This avoid updating while buffers are computed
    var updating: Bool = false
    
    // MARK: - Initialisation
    
    init(world: WorldBuffers) {
        self.world = world
        super.init()
    }
    
    // Used by Quartz when presenting layer
    override init(layer: Any) {
        let layer = layer as! ParticlesLayer
        world = layer.world
        super.init(layer: layer)
        drawsAsynchronously = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Update
    
    func update() {
        updating = true
        setNeedsDisplay()
    }
    
    override func draw(in ctx: CGContext) {
        
        ctx.saveGState()
        
        ctx.setFillColor(Color.black.cgColor)
        ctx.setStrokeColor(Color.white.cgColor)
        ctx.setLineWidth(0.5)

        var ray: CGFloat = 3
        
        for i in 0..<world.numberOfParticles {
            let p = world.particlesArray[i]
            var c = p.position / 2
            
            // We flip coordinates on MacOS
            #if os(macOS)
            c.y = bounds.height - c.y
            #endif
            ctx.setLineWidth(1)
            let tipx = min(20, 10 * sqrt(30 * abs(p.gravityVector.x))) * (p.gravityVector.x > 0 ? 1 : -1)
            let tipy = min(20, 10 * sqrt(30 * abs(p.gravityVector.y))) * (p.gravityVector.y > 0 ? 1 : -1)
            var tip = CGPoint(x: CGFloat(tipx), y: CGFloat(tipy))
            
#if os(macOS)
            tip.y = -tip.y
#endif
            ctx.move(to: c)
            ctx.addLine(to: c + tip)
            ctx.strokePath()
            
            let elementRect = CGRect(x: c.x - ray, y: c.y - ray, width: ray * 2, height: ray * 2)
            ctx.addEllipse(in: elementRect)
            ctx.drawPath(using: .fillStroke)

        }
        
        ray = 5
        ctx.setLineWidth(1.5)

        for i in 0..<world.numberOfAttractors {
            let a = world.attractorsArray[i] 
            var c = a.position  / 2
            
            // We flip coordinates on MacOS
            #if os(macOS)
            c.y = bounds.height - c.y
            #endif
            let particleRect = CGRect(x: c.x - ray, y: c.y - ray, width: ray * 2, height: ray * 2)
            ctx.addEllipse(in: particleRect)
            ctx.drawPath(using: .fillStroke)
        }
        
        ctx.restoreGState()
        updating = false
    }
    
}
