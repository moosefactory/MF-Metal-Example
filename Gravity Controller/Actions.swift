//
//  Actions.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 11/12/2020.
//

import MoofFoundation

/// All application actions are defined here
///
/// Actions are Int enums, so they can get mapped to control tags in the UI

/// User actions that control application parameters
enum ActionIdentifier: Int, CaseIterable {
    
    /// showHideMetalView : Show or hide the gravity fields renderer ( Metal View ).
    case showHideFields = 10
    
    /// showHideAttractors : Show or hide the particles view ( CALayer ).
    case showHideObjects = 11
    
    /// showHideControls : Show or hide the controls view.
    case showHideControls = 12
    
    /// randomize : Recreate random attractors.
    case randomize = 13
}

extension ActionIdentifier: ActionIdentifierProtocol {
    
    var identifier: String {
        switch self {
        case .showHideFields:
            return "showHideFields"
        case .showHideObjects:
            return "showHideObjects"
        case .showHideControls:
            return "showHideControls"
        case .randomize:
            return "randomize"
        }
    }
    
    var tag: Int { rawValue }
    
    var controlType: ActionControlType { return .button }
}

/// User actions that control World parameters
enum ParameterIdentifier: Int, CaseIterable {
    
    /// setComplexity : Set the number of attractors and attractors groups that will be created.
    case setNumberOfAttractors = 100
    
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
    
    /// setMinDistance : Set the minimal distance in the gravity formula.
    /// if < 1 , the resulting speed will go to infinity as we get close to 0
    case setMinDistance = 200
    
    /// setExponent : Set the distance exponent in the gravity formula. In our world, it is 2.
    case setExponent = 201
    
    /// setGravityConstant : Set the gravity constant.
    case setScale = 202
}


extension ParameterIdentifier: ParameterIdentifierProtocol {
        
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
        case .setNumberOfAttractors:
            return "setNumberOfAttractors"
        case .setParticlesGridSize:
            return "setParticlesGridSize"
        case .lockOnGrid:
            return "lockOnGrid"
        case .setSpringForce:
            return "setSpringForce"
        case .drawSpring:
            return "drawSpring"
        case .showParticles:
            return "showParticles"
        case .showAttractors:
            return "showAttractors"
        case .setMinDistance:
            return "setMinDistance"
        case .setExponent:
            return "setExponent"
        case .setScale:
            return "setScale"
        }
    }
    
    var tag: Int { rawValue }
    
    var min: Double {
        switch self {
        case .setNumberOfAttractors:
            return 1
        case .setExponent:
            return 1
        default:
            return 0
        }
    }
    
    var max: Double {
        switch self {
        case .setNumberOfAttractors:
            return 10
        case .setParticlesGridSize:
            return 80
        case .setSpringForce:
            return 1
        case .setMinDistance:
            return 500
        case .setExponent:
            return 5
        case .setScale:
            return 10
        default:
            return 1
        }

    }
    
    var `default`: Double {
        switch self {
        case .setNumberOfAttractors:
            return 5
        case .setParticlesGridSize:
            return 10
        case .lockOnGrid, .setSpringForce, .drawSpring:
            return 0
        case .showParticles:
            return 0
        case .showAttractors:
            return 1
        case .setMinDistance:
            return 2
        case .setExponent:
            return 2
        case .setScale:
            return 10
        }
    }

}
