//
//  Actions.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 11/12/2020.
//

import Foundation

enum Action: Int {
    case showHideMetalView = 100
    case showHideAttractors = 101
    case randomize = 102
    case showHideControls = 103
    case lockOnGrid = 110
    case drawSpring = 112

    case showParticles = 120
    case showAttractors = 121
}

enum SliderAction: Int {
    case setNumberOfAttractors = 100
    case setParticlesGridSize = 101
    
    case setSpringForce = 111
    
    case setMinDistance = 200
    case setExponent = 201
    case setScale = 202
}
