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
            startOrStopTimer()
        case .showHideObjects:
            particlesView.isHidden = !particlesView.isHidden
            startOrStopTimer()
        case .showHideControls:
            parametersView.isHidden = !parametersView.isHidden
        case .randomize:
            world.randomize()
        }
    }
    
    func startOrStopTimer() {
        let particlesLayerDisplaySomething = particlesView.particlesLayer.showParticles || particlesView.particlesLayer.showAttractors
        // Since we hide the metal view, the rendered closure won't be called anymore.
        // We start our timer to continue to update particles.
        if mtkView.isHidden && !particlesView.isHidden
            && particlesLayerDisplaySomething && world.particlesGridSize > 0 {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    func executeParameterAction(_ action: TypeErasedParameterProtocol) {
        selectedParameterView.setParameterAction = action
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
            startOrStopTimer()
            
        case .showAttractors:
            particlesView.particlesLayer.showAttractors = action.bool
            startOrStopTimer()
            
        case .lockOnGrid:
            world.lockParticles = action.bool

        // Sliders
        
        case .setComplexity:
            world.complexity = action.int
            
        case .setParticlesGridSize:
            world.particlesGridSize = action.int
            startOrStopTimer()
            
        case .setSpringForce:
            world.springForce = action.cgFloat
        default:
            break
        }
    }
    
}
