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
    
    var phase: CGFloat = 0
    
    var drawSpring: Bool = false {
        didSet {
            update()
        }
    }
    
    var showParticles: Bool = false {
        didSet {
            update()
        }
    }
    
    var showAttractors: Bool = false {
        didSet {
            update()
        }
    }
    
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

        if showParticles {
            renderParticles(in: ctx)
        }
        if showAttractors {
            renderAttractors(in: ctx)
        }
        
        ctx.restoreGState()
        updating = false
    }
    
    func renderParticles(in ctx: CGContext) {
        ctx.saveGState()
        var ray: CGFloat = 3
        
        ctx.setFillColor(Color.black.cgColor)
        ctx.setStrokeColor(Color.white.cgColor)

        for i in 0..<world.numberOfParticles {
            let p = world.particlesArray[i]
            var c = p.position / 2//.fromPositiveFractional(in: bounds)
            
            let g = p.gravityVector
            
            // We flip coordinates on MacOS
            #if os(macOS)
            c.y = bounds.height - c.y
            #endif
            
            if p.gravityPolarVector.x > 0.1 {
                ctx.setLineWidth(0.5)
                let tipx = min(20, 10 * sqrt(50 * abs(g.x))) * (g.x > 0 ? 1 : -1)
                let tipy = min(20, 10 * sqrt(50 * abs(g.y))) * (g.y > 0 ? 1 : -1)
                var tip = CGPoint(x: CGFloat(tipx), y: CGFloat(tipy))
                
                #if os(macOS)
                tip.y = -tip.y
                #endif
                ctx.move(to: c)
                ctx.addLine(to: c + tip)
                ctx.strokePath()
            }
            
            let da = CGFloat(p.distanceToAnchor)

            if drawSpring &&  da > 0.001 {
                var k = CGPoint(simd: p.anchorInView) / 2 //.fromPositiveFractional(in: bounds)
                #if os(macOS)
                k.y = bounds.height - k.y
                #endif
                let lw = 2.5 / (((da * 20) * (da * 20)).clamp(1, 18))
                ctx.setLineWidth(lw)
                ctx.setLineDash(phase: phase, lengths: [2,3])
                ctx.move(to: c)
                ctx.addLine(to: k)
                ctx.strokePath()
                ctx.setLineDash(phase: phase, lengths: [])
            }
            
            ctx.setLineWidth(0.8)

            let elementRect = CGRect(x: c.x - ray, y: c.y - ray, width: ray * 2, height: ray * 2)
            ctx.addEllipse(in: elementRect)
            ctx.drawPath(using: .fillStroke)
        }
        ctx.restoreGState()
    }
    
    func renderAttractors(in ctx: CGContext) {
        ctx.saveGState()
        ctx.setLineWidth(1.5)

        for i in 0..<world.numberOfAttractors {
            let a = world.attractorsArray[i]
            var c = a.position  / 2
            
            // We flip coordinates on MacOS
            #if os(macOS)
            c.y = bounds.height - c.y
            #endif
            
            let ray = CGFloat(a.mass / 100)
            let particleRect = CGRect(x: c.x - ray, y: c.y - ray, width: ray * 2, height: ray * 2)
            ctx.addEllipse(in: particleRect)
            ctx.drawPath(using: .fillStroke)
        }
        //phase -= 0.45
        ctx.restoreGState()
    }
    
}
