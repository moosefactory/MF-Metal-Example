//
//  World.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 09/12/2020.
//

import MoofFoundation

/// World is the Matrix that will be used to create buffers
///
/// This is a nice way to avoid multithreading issues.
///
/// World can be changed from UI at any time by the user, even while a calulator is accessing buffers while computing
///
/// A flag is set to tells the WorldBuffers will be responsible to recreate buffers at the right time

class World {
    
    /// UpdateFlag is used to set update granularity.
    /// It optimise performances to only recreate buffers that need it
    struct UpdateFlag: OptionSet {
        var rawValue: Int = 0
        
        static let particles = UpdateFlag(rawValue: 0x01)
        static let attractors = UpdateFlag(rawValue: 0x02)
        static let settings = UpdateFlag(rawValue: 0x04)
        
        static let all = UpdateFlag(rawValue: 0x07)
    }
    
    // We group elements in a struct to copy at once when passing to WorldBuffers
    //
    struct Objects {
        var particles = [Model.Particle]()
        var attractors = [Model.Attractor]()
        var groups = [Model.Group]()
        var settings = Model.Settings()
    }
    
    // MARK: - Properties
    
    private(set) var objects = Objects()

    var updateFlag = UpdateFlag()

    var settings: Model.Settings {
        get { objects.settings }
        set {
            objects.settings = newValue
            updateFlag.insert(.settings)
        }
    }
    var complexity: Int = 10 {
        didSet {
            makeWorld()
        }
    }
        
    var particlesGridSize: Int = 10 {
        didSet {
            makeParticles()
        }
    }

    /// Creates the attractors and groups
    ///
    /// We create a random number of root groups between 1 and 10
    /// Each group has a also random number of subgroups between 1 and 10
    /// Finally each group as a random number of attractors between 1 and 20
    init() {
        makeWorld()
    }
    
    ///  Create particles on a grid
    func makeParticles() {
        var newParticles = [Model.Particle]()
        let di = CGFloat(1) / CGFloat(particlesGridSize)
        let dj = CGFloat(1) / CGFloat(particlesGridSize)
        
        for i in 0..<particlesGridSize {
            for j in 0..<particlesGridSize {
                let loc = CGPoint(x: di / 2 + di * CGFloat(i) , y: dj / 2 + dj * CGFloat(j) )
                let particle = Model.Particle(location: loc)
                newParticles.append(particle)
            }
        }
        objects.particles = newParticles
        updateFlag.insert(.particles)
    }
    
    /// Create the world
    ///
    /// Random attractors will be created, depending of the complexity
    func makeWorld() {
        if updateFlag.contains(.attractors) {
            return
        }
        objects.groups = [Model.Group.root]
        objects.attractors = [Model.Attractor]()
        
        let maxNumberOfGroups = max(1, complexity / 4)
        let maxNumberOfSubGroups = max(1,complexity / 2)
        let maxNumberOfParticlesPerGroup = max(1,complexity)
        
        // Create between 1 and 10 groups
        let numberOfGroups = Int.random(in: 1...maxNumberOfGroups)
        var groupIndex: Int32 = 0
        
        for _ in 0..<numberOfGroups {
            let group = makeGroup(in: Model.Group.root, index: &groupIndex)
            objects.groups.append(group)
            
            // Create between 1 and 10 sub groups
            let numberOfSubGroups = Int.random(in: 1...maxNumberOfSubGroups)
            for _ in 0..<numberOfSubGroups {
                let subGroup = makeGroup(in: group, index: &groupIndex)
                objects.groups.append(subGroup)
            }
        }
        
        // Compute attractors - we create between 1 and 20 attractors in each groups
        objects.groups.forEach { group in
            let numberOfAttractors = Int.random(in: 1...maxNumberOfParticlesPerGroup)
            objects.attractors += makeAttractors(in: group, count: numberOfAttractors)
        }
        
        updateFlag.insert(.attractors)
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

