//
//  Actions+Fields.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 13/12/2020.
//

import MoofFoundation


/// User actions that control World parameters
enum FieldsParametersIdentifier: Int, CaseIterable {
        
    /// setMinDistance : Set the minimal distance in the gravity formula.
    /// if < 1 , the resulting speed will go to infinity as we get close to 0
    case setMinDistance = 200
    
    /// setExponent : Set the distance exponent in the gravity formula. In our world, it is 2.
    case setExponent = 201
    
    /// setGravityConstant : Set the gravity constant.
    case setGravity = 202
    
    /// setGravityConstant : Set the gravity constant.
    case setScale = 203
    
    /// setGravityConstant : Set the gravity constant.
    case invertColors = 210

    case showHideFields = 211
    
    /// setComplexity : Set the number of attractors and attractors groups that will be created.
    case setComplexity = 100

    /// setGravityConstant : Set the gravity constant.
    case setFieldsSensitivity = 212

    static var sliders: [FieldsParametersIdentifier] {
        return [.setComplexity, setFieldsSensitivity, .setGravity, .setMinDistance, .setExponent, .setScale]
    }

    
    static var switches: [FieldsParametersIdentifier] {
        return [.showHideFields, .invertColors]
    }
}


extension FieldsParametersIdentifier: ParameterIdentifierProtocol {
        
    var controlType: ActionControlType {
        switch self {
        case .invertColors, .showHideFields:
        return .switch
        default:
            return .slider
        }
    }
    
    var identifier: String {
        switch self {
        case .showHideFields:
            return "ShowHideFields"
        case .setMinDistance:
            return "SetMinDistance"
        case .setExponent:
            return "SetExponent"
        case .setGravity:
            return "SetGravity"
        case .setScale:
            return "SetScale"
        case .invertColors:
            return "InvertColors"
        case .setComplexity:
            return "SetComplexity"
        case .setFieldsSensitivity:
            return "FieldsSensitivity"

        }
    }
    
    var tag: Int { rawValue }
    
    var min: Double {
        switch self {
        case .setExponent:
            return 0.5
        case .setScale:
            return 0.1
        case .setComplexity:
            return 1
        case .setFieldsSensitivity:
            return 0.01
        default:
            return 0
        }
    }
    
    var max: Double {
        switch self {
        case .setComplexity:
            return 25
        case .setFieldsSensitivity:
            return 200
        case .setMinDistance:
            return 800
        case .setExponent:
            return 4
        case .setGravity:
            return 20
        case .setScale:
            return 5
        default:
            return 1
        }
    }
    
    var `default`: Double {
        switch self {
        case .setComplexity:
            return 5
        case .setFieldsSensitivity:
            return 10
        case .setMinDistance:
            return 2
        case .setExponent:
            return 2
        case .setGravity:
            return 3
        case .setScale:
            return 1
        case .showHideFields:
            return 1
        default:
            return 0
        }
    }

}
