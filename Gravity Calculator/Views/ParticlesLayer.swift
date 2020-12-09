//
//  ParticlesLayer.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 09/12/2020.
//

import MoofFoundation
import Quartz

class ParticleLayer: CALayer {
    
    var ray: CGFloat = 1.5
    var superFrame: CGRect = .zero
    var particle: Model.Particle {
        didSet {
            position = particle.position
        }
    }
    
    init(particle: Model.Particle, frame: CGRect) {
        self.particle = particle
        self.superFrame = frame
        super.init()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var pos: CGPoint {
        return CGPoint(simd: particle.location)//.fromPositiveFractional(in: superFrame)
    }
    
    func update() {
        // Make the layer large enough to render gravity vector
        let outerRay: CGFloat = min(100, max(ray, sqrt(abs(CGFloat(particle.gravityPolarVector.x) * 100000))))
        self.frame = CGRect(x: pos.x / 2 - outerRay, y: (superFrame.height - pos.y / 2) - outerRay, width: outerRay * 2, height: outerRay * 2)
        setNeedsDisplay()
    }
    
    override func draw(in ctx: CGContext) {
        let c = center
        let particleRect = CGRect(x: c.x - ray, y: c.y - ray, width: ray * 2, height: ray * 2)
        ctx.addEllipse(in: particleRect)
        ctx.setFillColor(Color.black.cgColor)
        ctx.setStrokeColor(Color.white.cgColor)
        ctx.setLineWidth(1)
        ctx.drawPath(using: .fillStroke)
        ctx.setLineWidth(2)
        let tipx = min(100,sqrt(abs(particle.gravityVector.x) * 100000)) * (particle.gravityVector.x > 0 ? 1 : -1)
        let tipy = -min(100,sqrt(abs(particle.gravityVector.y) * 100000)) * (particle.gravityVector.y > 0 ? 1 : -1)
        let tip = CGPoint(x: CGFloat(tipx), y: CGFloat(tipy))
        ctx.move(to: c)
        ctx.addLine(to: c + tip)
        ctx.strokePath()
    }
}

class AttractorLayer: CALayer {
    
    var ray: CGFloat = 2
    var superFrame: CGRect = .zero
    var attractor: Model.Attractor
    
    init(attractor: Model.Attractor, frame: CGRect) {
        self.attractor = attractor
        self.superFrame = frame
        super.init()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var pos: CGPoint {
        return CGPoint(simd: attractor.location)//.fromPositiveFractional(in: superFrame)
    }
    
    func update() {
        // Make the layer large enough to render gravity vector
        self.frame = CGRect(x: pos.x / 2 - ray, y: (superFrame.height - pos.y / 2) - ray, width: ray * 2, height: ray * 2)
        setNeedsDisplay()
    }
    
    override func draw(in ctx: CGContext) {
        let c = center
        let particleRect = CGRect(x: c.x - ray, y: c.y - ray, width: ray * 2, height: ray * 2)
        ctx.addEllipse(in: particleRect)
        ctx.setFillColor(Color.black.cgColor)
        ctx.setStrokeColor(Color.white.cgColor)
        ctx.setLineWidth(1)
        ctx.drawPath(using: .fillStroke)
        ctx.setLineWidth(1)
    }
}

class ParticlesLayer: CALayer {
    
    var world: WorldBuffers
    
    init(world: WorldBuffers) {
        self.world = world
        super.init()
        rebuildParticleLayers()
        backgroundColor = Color.red.with(alpha: 0.1).cgColor
    }
    
    override init(layer: Any) {
        let layer = layer as! ParticlesLayer
        world = layer.world
        
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func rebuildParticleLayers() {
        guard world.world.particles.count > 0 else { return }
        for i in 0..<world.world.particles.count {
            let particle = world.particlesArray[i]
            let p = ParticleLayer(particle: particle, frame: bounds)
            addSublayer(p)
            p.setNeedsDisplay()
        }
        setNeedsDisplay()
    }
    
    func rebuildAttractorsLayers() {
        guard world.world.attractors.count > 0 else { return }
        for i in 0..<world.world.attractors.count {
            let attractor = world.attractorsArray[i]
            let a = AttractorLayer(attractor: attractor, frame: bounds)
            addSublayer(a)
            a.setNeedsDisplay()
        }
        setNeedsDisplay()
    }

    func update() {
        removeAllSublayers()
        rebuildParticleLayers()
        rebuildAttractorsLayers()
    }
}
