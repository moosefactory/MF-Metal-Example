//
//  Model.swift
//  Gravitic
//
//  Created by Tristan Leblanc on 22/11/2020.
//  Copyright © 2020 Moose Factory Software. All rights reserved.
//

import Foundation
import QuartzCore
import simd


public protocol WorldElement {
    var location: simd_float2 { get }
}

public extension WorldElement {
    var position: CGPoint { CGPoint(simd: location) }
}

public struct Model {
    
    
    public struct Group: WorldElement {
        // Group index. Group index is unique among all groups. Index 0 is root group.
        let index: simd_int1
        let superGroupIndex: simd_int1

        public let location: simd_float2
        let rotationSpeed: simd_float1
        let scale: simd_float1
        
        static let root = Group(index: 0, superGroupIndex: 0, location: [0,0], rotationSpeed: 0, scale: 1)
    }
    
    public struct Attractor: WorldElement {
        let groupIndex: simd_int1

        public let location: simd_float2
        let rotationSpeed: simd_float1
        
        let mass: simd_float1
        let color: simd_float4
    }
    
    public struct Particle: WorldElement {
        
        public let location: simd_float2
        let mass: simd_float1
        let color: simd_float4
        
        // Will be computed by Particles Calculator

        let gravityVector: simd_float2
        let gravityPolarVector: simd_float2
    }
    
    public struct Settings {
        var frame: simd_int1 = 0
        var width: simd_int1 = 0
        var height: simd_int1 = 0
        var radius: simd_float1 = 0
        
        var numberOfAttractors: simd_int1 = 0
        var numberOfGroups: simd_int1 = 0
        var numberOfParticles: simd_int1 = 0
        var numberOfParticlesPerGroup: simd_int1 = 0
        
        var minimalDistance: simd_float1 = 0
        var gravityFactor: simd_float1 = 0.1
        var gravityExponent: simd_float1 = 2
    }
}

public extension Model.Particle {
    var position: CGPoint { return CGPoint(x: CGFloat(location.x), y: CGFloat(location.y))}
}

public extension Model.Attractor {

    func positionned(at frameIndex: Int, in frame: CGRect, in group: [Model.Group]) -> Model.Attractor {
        let width = Float(frame.width / 2)
        let height = Float(frame.height / 2)
        let ray = Float(max(width, height));

        var groupid = groupIndex
        var polarLocation =  location
        
        let rho = polarLocation.x * ray * group[Int(groupid)].scale;
        let theta = polarLocation.y + Float(frameIndex) * rotationSpeed;
        var offset: simd_float2 = .zero;
        
        offset.x += rho * cos(theta);
        offset.y += rho * sin(theta);

        // convert location from group to rootGroup
        while (true) {
            if (groupid == 0) {
                break;
            }
            
            polarLocation = group[Int(groupid)].location;

            // Move to upper group
            groupid = group[Int(groupid)].superGroupIndex;
            
            let rho = polarLocation.x * ray * group[Int(groupid)].scale;
            let theta = polarLocation.y + Float(frameIndex) * group[Int(groupid)].rotationSpeed;

            offset.x += rho * cos(theta);
            offset.y += rho * sin(theta);
        }
        
        offset.x += width;
        offset.y += height
        return Model.Attractor(groupIndex: groupid,
                                           location: offset,
                                           rotationSpeed: rotationSpeed,
                                           mass: mass,
                                           color: color)
    }

}
