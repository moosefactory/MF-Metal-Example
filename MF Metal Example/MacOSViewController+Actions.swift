//
//  MacOSViewController+Actions.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 11/12/2020.
//

import Foundation
import Cocoa

extension MacOSViewController {
    
    
    func executeAppAction(_ action: ActionIdentifier) {
        switch action {
        case .showHideFields:
            mtkView.isHidden = !mtkView.isHidden
            // Since we hide the metal view, the rendered closure won't be called anymore.
            // We start our timer to continue to update particles.
            if mtkView.isHidden && !particlesView.isHidden {
                startTimer()
            } else {
                stopTimer()
            }
        case .showHideObjects:
            particlesView.isHidden = !particlesView.isHidden
        case .showHideControls:
            controlsView.isHidden = !controlsView.isHidden
        case .randomize:
            world.randomize()
        }
    }
    
    func executeParameterAction(_ action: TypeErasedParameterProtocol) {
        switch action.identifier {
        case .setExponent:
            world.gravityExponent = action.cgFloat
            
        case .setMinDistance:
            world.minimalDistance = action.cgFloat
            
        case .setScale:
            world.gravityFactor = action.cgFloat

        case .drawSpring:
            particlesView.particlesLayer.drawSpring = action.bool
            
        case .showParticles:
            particlesView.particlesLayer.showParticles = action.bool
            
        case .showAttractors:
            particlesView.particlesLayer.showAttractors = action.bool

        case .lockOnGrid:
            world.lockParticles = action.bool

        // Sliders
        
        case .setNumberOfAttractors:
            world.complexity = action.int
            
        case .setParticlesGridSize:
            world.particlesGridSize = action.int
            
            
        case .setSpringForce:
            world.springForce = action.cgFloat
        default:
            break
        }
    }
    
}
