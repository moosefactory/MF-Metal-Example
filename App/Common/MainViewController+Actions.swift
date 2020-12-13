//
//  MainViewController+Actions.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 11/12/2020.
//

import Foundation

extension MainViewController {
    
    func executeAppAction(_ action: ActionIdentifier) {
        switch action {
        case .showHideFields:
            fieldsParamControlsBox.isHidden = !fieldsParamControlsBox.isHidden
            particlesParamControlsBox.isHidden = true
            fieldsParamControlsBox.stack.insertArrangedSubview(selectedParameterView, at: 1)
        case .showHideControls:
            particlesParamControlsBox.isHidden = !particlesParamControlsBox.isHidden
            fieldsParamControlsBox.isHidden = true
            particlesParamControlsBox.stack.insertArrangedSubview(selectedParameterView, at: 1)
        case .randomize:
            world.randomize()
        }
    }
    
    func startOrStopTimer() {
        let particlesLayerDisplaySomething = particlesView.particlesLayer.showParticles || particlesView.particlesLayer.showAttractors
        // Since we hide the metal view, the rendered closure won't be called anymore.
        // We start our timer to continue to update particles.
        if mtkView.isHidden && !particlesView.isHidden
            && particlesLayerDisplaySomething {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    func executeParameterAction(_ action: TypeErasedSetParameterActionProtocol) {
        if action.identifier is ParticlesParametersIdentifier {
            executeParticlesAction(action)
        }
        if action.identifier is FieldsParametersIdentifier {
            executeFieldsAction(action)
        }
    }
    
    
    func executeFieldsAction(_ action: TypeErasedSetParameterActionProtocol) {
        selectedParameterView.setParameterAction = action
        let identifier = action.identifier as! FieldsParametersIdentifier
        switch identifier {
        case .setExponent:
            world.gravityExponent = action.cgFloat
        case .setMinDistance:
            world.minimalDistance = action.cgFloat
        case .setGravity:
            world.gravityFactor = action.cgFloat
        case .setScale:
            world.scale = action.cgFloat
        case .invertColors:
            world.invertColors = action.bool
        case .showHideFields:
            mtkView.isHidden = !action.bool
            startOrStopTimer()
        case .setComplexity:
            world.complexity = action.int
        case .setFieldsSensitivity:
            world.fieldsSensitivity = action.cgFloat
        }
    }
    
    func executeParticlesAction(_ action: TypeErasedSetParameterActionProtocol) {
        selectedParameterView.setParameterAction = action
        let identifier = action.identifier as! ParticlesParametersIdentifier
        switch identifier {
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
        
        case .setParticlesGridSize:
            world.particlesGridSize = action.int
            startOrStopTimer()
            
        case .setSpringForce:
            world.springForce = action.cgFloat
        case .setParticlesSensitivity:
            world.particlesSensitivity = action.cgFloat
        }
    }
    
}
