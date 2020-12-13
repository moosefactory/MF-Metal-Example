//
//  Model.swift
//  Gravitic
//
//  Created by Tristan Leblanc on 22/11/2020.
//  Copyright © 2020 Moose Factory Software. All rights reserved.
//

import MoofFoundation
import QuartzCore
import simd


public protocol WorldElement {
    var location: simd_float2 { get }
}

public extension WorldElement {
    var position: CGPoint { CGPoint(simd: location) }
}

public struct Model {
    
    /// The environment variables

    public struct Environment: Codable {
        var frame: simd_int1 = 0
        var width: simd_int1 = 0
        var height: simd_int1 = 0
        var radius: simd_float1 = 0
        
        var numberOfAttractors: simd_int1 = 0
        var numberOfGroups: simd_int1 = 0
        var numberOfParticles: simd_int1 = 0
        
        var numberOfParticlesPerThreadGroup: simd_int1 = 0
        var numberOfAttractorsPerThreadGroup: simd_int1 = 0

        // User settings
        
        var minimalDistance: simd_float1 = 0
        var gravityFactor: simd_float1 = 1
        var gravityExponent: simd_float1 = 2

        var scale: simd_float1 = 1
        var fieldsSensitivity: simd_float1 = 1
        var particlesSensitivity: simd_float1 = 1
        
        var invertColors: Bool = false
        
        var lockParticles: Bool = false
        var spring: simd_float1 = 0
    }

    
    public struct Attractor: WorldElement, Codable {
        let groupIndex: simd_int1
        public let anchor: simd_float2
        let rotationSpeed: simd_float1
        let mass: simd_float1
        let color: simd_float4
        
        public let polarLocation: simd_float2 = .zero
        public let planarLocation: simd_float2 = .zero
        public let location: simd_float2 = .zero
    }

    public struct Group: WorldElement, Codable {
        // Group index. Group index is unique among all groups. Index 0 is root group.
        let index: simd_int1
        let superGroupIndex: simd_int1

        public let anchor: simd_float2
        let rotationSpeed: simd_float1
        let scale: simd_float1
        
        public let polarLocation: simd_float2 = .zero
        public let planarLocation: simd_float2 = .zero
        public let location: simd_float2 = .zero

        static let root = Group(index: 0, superGroupIndex: 0, anchor: [0,0], rotationSpeed: 0, scale: 1)
    }
    
    public struct Particle: WorldElement {
        /// The initial particle location
        /// - If gridLock is true, then location will stick to anchor
        /// - If spring is set, then a force will attract particle to it's anchor
        public let anchor: simd_float2
        /// The particle mass
        let mass: simd_float1
        /// Particle color
        let color: simd_float4
        
        // ----> Will be computed by Particles Calculator

        /// The mighty gravity force
        let gravityVector: simd_float2 = .zero
        /// The mighty gravity force expressed in polar coordinate
        let gravityPolarVector: simd_float2 = .zero
        
        /// The distance to anchor
        let distanceToAnchor: simd_float1 = .zero
        
        /// The fractional location
        public let planarLocation: simd_float2
        /// The location in view
        public let location: simd_float2 = .zero
        /// The anchor location in view
        public let anchorInView: simd_float2 = .zero

        // <---
        
        init(location: CGPoint, mass: CGFloat = 1, color: Color = .white) {
            self.anchor = location.simd
            self.mass = mass.simd
            self.color = color.simd
            self.planarLocation = anchor
        }
    }
}

public extension Model.Particle {
    var position: CGPoint { return CGPoint(x: CGFloat(location.x), y: CGFloat(location.y))}
}
