//
//  World+UI.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 11/12/2020.
//

import Foundation

/// World+UI
///
/// A collection of convenient getters/setters to wire UI

extension World {
    
    // MARK: - User actions
    
    func randomize() {
        makeWorld()
    }

    // MARK: - Convenience getters/setters to wire settings and UI

    var gravityFactor: CGFloat {
        set {
            settings.gravityFactor = newValue.simd
            updateFlag = .settings
        }
        get { return CGFloat(settings.gravityFactor) }
    }
    
    var gravityExponent: CGFloat {
        set {
            settings.gravityExponent = newValue.simd
            updateFlag = .settings
        }
        get { return CGFloat(settings.gravityExponent) }
    }
    
    var minimalDistance: CGFloat {
        set {
            settings.minimalDistance = newValue.simd
            updateFlag = .settings
        }
        get { return CGFloat(settings.minimalDistance) }
    }
    
    var lockParticles: Bool {
        set {
            settings.lockParticles = newValue
            updateFlag = .settings
        }
        get { return Bool(settings.lockParticles) }
    }

    var springForce: CGFloat {
        set {
            settings.spring = newValue.simd
            updateFlag = .settings
        }
        get { return CGFloat(settings.spring) }
    }

}
