//
//  World.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 09/12/2020.
//

import MoofFoundation

class World {
    
    var particles = [Model.Particle]()
    var attractors = [Model.Attractor]()
    var groups = [Model.Group]()
    
    var settings = Model.Settings()
    var frameIndex: Int = 0
    
    var worldChangedClosure: (()->Void)?
    
    var needsRecreateBuffer: Bool = false
    
    // Settings
    
    
    var complexity: Int = 10 {
        didSet {
            needsRecreateBuffer = true
        }
    }
    
    func recreateBuffersIfNeeded() {
        guard needsRecreateBuffer else { return }
        makeWorld()
        makeParticles()
        worldChangedClosure?()
        needsRecreateBuffer = false
    }
    
    var numberOfParticles: Int = 1000 {
        didSet {
            needsRecreateBuffer = true
        }
    }
    
    var gravityFactor: CGFloat {
        set {
            settings.gravityFactor = newValue.simd
            worldChangedClosure?()
        }
        get { return CGFloat(settings.gravityFactor) }
    }
    
    var gravityExponent: CGFloat {
        set {
            settings.gravityExponent = newValue.simd
            worldChangedClosure?()
        }
        get { return CGFloat(settings.gravityExponent) }
    }
    
    var minimalDistance: CGFloat {
        set {
            settings.minimalDistance = newValue.simd
            worldChangedClosure?()
        }
        get { return CGFloat(settings.minimalDistance) }
    }
    
    /// Creates the attractors and groups
    ///
    /// We create a random number of root groups between 1 and 10
    /// Each group has a also random number of subgroups between 1 and 10
    /// Finally each group as a random number of attractors between 1 and 20
    init() {
        makeWorld()
    }
    
    func randomize() {
        makeWorld()
    }
    
    func makeParticles() {
        particles = [Model.Particle]()
        for i in 0..<numberOfParticles {
            for j in 0..<numberOfParticles {
                let loc = CGPoint(x: CGFloat(i) / CGFloat(numberOfParticles), y: CGFloat(j) / CGFloat(numberOfParticles) )
                let color = Color(red: 0, green: 0.3, blue: 0.9, alpha: 0.9)
                let particle = Model.Particle(location: loc.simd,
                                              mass: 1, color: color.simd,
                                              gravityVector: .zero,
                                              gravityPolarVector: .zero)
                particles.append(particle)
            }
        }
    }
    
    func makeWorld() {
        
        groups = [Model.Group.root]
        attractors = [Model.Attractor]()
        
        let maxNumberOfGroups = max(1, complexity / 4)
        let maxNumberOfSubGroups = max(1,complexity / 2)
        let maxNumberOfParticlesPerGroup = max(1,complexity)
        
        // Create between 1 and 10 groups
        let numberOfGroups = Int.random(in: 1...maxNumberOfGroups)
        var groupIndex: Int32 = 0
        
        for _ in 0..<numberOfGroups {
            let group = makeGroup(in: Model.Group.root, index: &groupIndex)
            groups.append(group)
            
            // Create between 1 and 10 sub groups
            let numberOfSubGroups = Int.random(in: 1...maxNumberOfSubGroups)
            for _ in 0..<numberOfSubGroups {
                let subGroup = makeGroup(in: group, index: &groupIndex)
                groups.append(subGroup)
            }
        }
        
        // Compute attractors - we create between 1 and 20 attractors in each groups
        groups.forEach { group in
            let numberOfAttractors = Int.random(in: 1...maxNumberOfParticlesPerGroup)
            attractors += makeAttractors(in: group, count: numberOfAttractors)
        }
    }
    
    /// Make a group
    ///
    /// Each group as a random rotation speed. Group will rotate around supergroup center, or view center if it is a root group
    ///
    /// index is incremented automatically each time a group is added
    func makeGroup(in group: Model.Group, index: inout Int32) -> Model.Group {
        let rho = CGFloat.random()
        let theta = CGFloat.randomAngle()
        let rotSpeed = sqrt(CGFloat.randomAngle()) / 400
        let scale = CGFloat(group.scale) * (0.6 + CGFloat.random() * 0.2)
        
        // We increment index before creating the group - Index 0 is reserved for the root group
        index += 1
        return Model.Group(index: index,
                           superGroupIndex: group.index,
                           location:  [Float(rho), Float(theta)],
                           rotationSpeed: Float(rotSpeed),
                           scale: Float(scale))
    }
    
    /// Make an attractor
    ///
    /// We create an attractor with random rotation speed, mass and color
    ///
    /// Location is expressed in polar coordinates
    func makeAttractors(in group: Model.Group, count: Int) -> [Model.Attractor] {
        var attractors = [Model.Attractor]()
        for _ in 0..<count {
            
            let rho = CGFloat.random()
            let theta = CGFloat.randomAngle()
            
            let rotSpeed = sqrt(CGFloat.randomAngle()) / 200
            
            let r = CGFloat.random()
            let g = CGFloat.random() * 0.5
            let b = CGFloat.random()
            let a = 0
            
            let attractor = Model.Attractor(groupIndex: group.index,
                                            location: [Float(rho), Float(theta)],
                                            rotationSpeed: Float(rotSpeed),
                                            mass: Float( 1 + CGFloat.random() * 1000),
                                            color: [Float(r), Float(g), Float(b), Float(a)])
            attractors += [attractor]
        }
        return attractors
    }
}

