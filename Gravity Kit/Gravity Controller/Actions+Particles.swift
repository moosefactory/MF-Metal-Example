//
//  Actions+Particles.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 13/12/2020.
//

import MoofFoundation


//protocol ParameterIdentifierProtocol {
//    
//}

/// User actions that control World parameters
enum ParticlesParametersIdentifier: Int, CaseIterable {
        
    /// setParticlesGridSize : Set the particles grid size. Number of particles will be gridSize^2.
    case setParticlesGridSize = 101

    /// Lock particles on the grid.
    case lockOnGrid = 110

    /// setSpringForce : Set the spring force.
    /// - O : Spring can grow infinitely
    /// - 1 : Spring can't grow - Equivalent to gridLock
    case setSpringForce = 111
    
    /// drawSpring : Draw the spring that pull particles back to their position on grid.
    case drawSpring = 112

    /// showParticles : Render the particles in the particles view.
    case showParticles = 120
    
    /// showAttractors : Render the attractors in the particles view.
    case showAttractors = 121
        
    /// setGravityConstant : Set the gravity constant.
    case setParticlesSensitivity = 211

    
    static var sliders: [ParticlesParametersIdentifier] {
        return [.setParticlesGridSize, .setSpringForce, .setParticlesSensitivity]
    }

    
    static var switches: [ParticlesParametersIdentifier] {
        return [.showParticles, .showAttractors, .lockOnGrid, .drawSpring]
    }
}


extension ParticlesParametersIdentifier: ParameterIdentifierProtocol {
        
    var controlType: ActionControlType {
        switch self {
        case .lockOnGrid, .drawSpring:
            return .switch
        case .showParticles, .showAttractors:
            return .switch
        default:
            return .slider
        }
    }
    
    var identifier: String {
        switch self {
        case .setParticlesSensitivity:
            return "ParticlesSensitivity"
        case .setParticlesGridSize:
            return "SetParticlesGridSize"
        case .lockOnGrid:
            return "LockOnGrid"
        case .setSpringForce:
            return "SetSpringForce"
        case .drawSpring:
            return "DrawSpring"
        case .showParticles:
            return "ShowParticles"
        case .showAttractors:
            return "ShowAttractors"
        }
    }
    
    var tag: Int { rawValue }
    
    var min: Double {
        switch self {
        case .setParticlesSensitivity:
            return 0.01
        default:
            return 0
        }
    }
    
    var max: Double {
        switch self {
        case .setParticlesGridSize:
            return 80
        case .setSpringForce:
            return 0.2
        case .setParticlesSensitivity:
            return 100
        default:
            return 1
        }

    }
    
    var `default`: Double {
        switch self {
        case .setParticlesGridSize:
            return 10
        case .setParticlesSensitivity:
            return 1
        case .lockOnGrid, .setSpringForce, .drawSpring:
            return 0
        case .showParticles, .showAttractors:
            return 0
        }
    }
}
