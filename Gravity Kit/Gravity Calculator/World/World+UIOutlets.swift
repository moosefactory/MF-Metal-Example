//
//  World+UI.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 11/12/2020.
//

import Foundation
import QuartzCore

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

    
    var fieldsSensitivity: CGFloat {
        set {
            settings.fieldsSensitivity = newValue.simd
            updateFlag = .settings
        }
        get { return CGFloat(settings.fieldsSensitivity) }
    }
    
    var particlesSensitivity: CGFloat {
        set {
            settings.particlesSensitivity = newValue.simd
            updateFlag = .settings
        }
        get { return CGFloat(settings.particlesSensitivity) }
    }
    
    var scale: CGFloat {
        set {
            settings.scale = newValue.simd
            updateFlag = .settings
        }
        get { return CGFloat(settings.scale) }
    }

    var invertColors: Bool {
        set {
            settings.invertColors = newValue
            updateFlag = .settings
        }
        get { return Bool(settings.invertColors) }
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
