//
//  MacOSViewController+Actions.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 11/12/2020.
//

import Foundation
import Cocoa

extension MacOSViewController {
    
    @IBAction func buttonTapped(_ sender: NSButton) {
        guard let action = Action(rawValue: sender.tag) else { return }
        
        switch action {
        
                        
        case .randomize:
            world.randomize()
            
        case .showHideControls:
            controlsView.isHidden = !controlsView.isHidden
            
        case .drawSpring:
            particlesView.particlesLayer.drawSpring = sender.state == NSControl.StateValue.on
            
        case .showParticles:
            particlesView.particlesLayer.showParticles = sender.state == NSControl.StateValue.on
            
        case .showAttractors:
            particlesView.particlesLayer.showAttractors = sender.state == NSControl.StateValue.on

        case .lockOnGrid:
            world.lockParticles = sender.state == NSControl.StateValue.on
            
        case .showHideAttractors:
            particlesView.isHidden = !particlesView.isHidden

        case .showHideMetalView:
            mtkView.isHidden = !mtkView.isHidden

            // Since we hide the metal view, the rendered closure won't be called anymore.
            // We start our timer to continue to update particles.
            if mtkView.isHidden && !particlesView.isHidden {
                startTimer()
            }
            else {
                stopTimer()
            }
        }
    }
    
    @IBAction func sliderChanged(_ sender: NSSlider) {
        guard let action = SliderAction(rawValue: sender.tag) else { return }
        switch action {
        
        case .setNumberOfAttractors:
            world.complexity = Int(sender.intValue)
            
        case .setParticlesGridSize:
            world.particlesGridSize = Int(sender.intValue)
            
        case .setExponent:
            world.gravityExponent = CGFloat(sender.doubleValue / 10)
            
        case .setMinDistance:
            world.minimalDistance = CGFloat(sender.doubleValue / 10)
            
        case .setScale:
            world.gravityFactor = CGFloat(sender.doubleValue / 10)
            
        case .setSpringForce:
            world.springForce = CGFloat(sender.doubleValue)
        }
    }
    
}
