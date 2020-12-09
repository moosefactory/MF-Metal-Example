//
//  ParticlesCalculator.metal
//  MF Metal Example
//
//  Created by Tristan Leblanc on 09/12/2020.
//

#include <metal_stdlib>
#include "../Model/Model+GPU.metal"

using namespace metal;

kernel void computeParticlesForces(device Particle* p,
                                 device const Attractor* a,
                                 device const Environment* settings,
                                 uint2 gid [[thread_position_in_grid]])
{
    
    // Convert the thread position in grid to particle index in particles buffer
    uint particleIndexInGroup = float(gid.x);
    uint particlesGroupIndex = float(gid.y);
    
    uint particleIndex = particlesGroupIndex * settings->numberOfParticlesPerGroup + particleIndexInGroup;
    float2 particleLocation = p[particleIndex].location;
    
    float g = 0;
    float d = 0;
    float2 gVec = 0;
    
    float n = settings->numberOfAttractors;
    
    // Iterates through attractors to compute gravity vector for particle
    
    for (uint i=0; i<n; i++) {
        float2 attractorLocation = a[i].location;

        // Compute distance and gravity
        d = max(settings->minimalDistance, distance(attractorLocation, particleLocation));
        g = settings->gravityFactor * a[i].mass / pow(d, settings->gravityExponent);
        
        // Computes unit vector
        float2 u = (attractorLocation - particleLocation) / d;
        
        // Computes gravity vector
        gVec += u * g;
    }
    
    // set g to final gravity, computed from gravity vector length
    g = distance(0, gVec);

    p[particleIndex].gravityVector = gVec;
    p[particleIndex].gravityPolarVector.x = g;
    p[particleIndex].gravityPolarVector.y = atan2(gVec.y, gVec.x);
}

