//
//  Model.metal
//  Gravitic
//
//  Created by Tristan Leblanc on 22/11/2020.
//  Copyright © 2020 Moose Factory Software. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

/// Environment
///
/// This structure holds our settings, and all properties we find usefull to be shared with
/// the metal calculators.

struct Environment {
    // Render informations, frame index, drawable width and height.
    // We also pass the radius of the smallest circle containing the drawable area ( the distance corner to corner ).
    // This is usefull to determine the scale. We pass a float, because we will usually use it in floating point computations
    uint frame;
    uint width;
    uint height;
    float radius;
    
    // We pass the size of the number of elements in buffers, this can be usefull to compute scales.
    // ( element offset / number of elements )
    uint numberOfAttractors;
    uint numberOfGroups;
    
    // This is used in particles calculator
    //
    // Particles are splitted in groups, each group will be dispatched in its own thread
    uint numberOfParticles;
    
    uint numberOfParticlesPerThreadGroup;
    uint numberOfAttractorsPerThreadGroup;
    
    // The user settings
    
    float minimalDistance;
    float gravityFactor;
    float gravityExponent;
    
    float scale;
    float fieldsSensitivity;
    float particlesSensitivity;
    bool invertColor;
    bool lockParticles;
    float spring;
};

/// Attractor
///
/// Attractors are attached to a group
/// All attractors of a same group are rotating around the center of this group.
struct Attractor {
    int groupIndex;
    /// anchor is the initial, unscaled ( in [-1..1] range ) location of the attractor
    /// it will be used to compute location from frame index
    float2 anchor;
    
    float rotationSpeed;
    float mass;
    float4 color;
    
    // Computed polar location
    float2 polarLocation;
    // Computed planar fractional location
    float2 planarLocation;
    // Computed location in drawable
    float2 location;
};

/// Group
///
/// Groups contains attractors. They can be contained in a group themselves, in which case they also rotate
/// around the center of the containing group.
///
/// Group with index 0 is the root group, it's scale is 1, which corresponds to the view size.
struct Group {
    uint index;
    uint superGroupIndex;
    /// anchor is the initial location of the group
    /// it will be used to compute location from frame index
    float2 anchor;
    float rotationSpeed;
    float scale;
    
    // Computed polar location
    float2 polarLocation;
    // Computed planar fractional location
    float2 planarLocation;
    // Computed location in drawable
    float2 location;
};

/// Particle
///
/// Particles are free bodies that can be anywhere and are subjects to gravity.
/// anchor represents the initial location.

struct Particle {
    float2 anchor;
    float mass;
    float4 color;
    
    // Will be computed by Particles Calculator
    
    float2 gravityVector;
    float2 gravityPolarVector;
    float distanceToAnchor;

    // Computed planar fractional location
    float2 planarLocation;
    // Computed location in drawable
    float2 location;
    float2 anchorInView;
};
