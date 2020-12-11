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
    
    uint i = particlesGroupIndex * settings->numberOfParticlesPerGroup + particleIndexInGroup;
    float2 particleLocation = p[i].location;
    float2 anchor = p[i].anchor;
    
    // TODO: Remove an use fracional location
    particleLocation.x *= settings->width;
    particleLocation.y *= settings->height;
    anchor.x *= settings->width;
    anchor.y *= settings->height;

    float g = 0;
    float d = 0;
    float2 gVec = 0;
    
    float n = settings->numberOfAttractors;
    
    // Iterates through attractors to compute gravity vector for particle
    
    for (uint j=0; j<n; j++) {
        float2 attractorLocation = a[j].location;

        // Compute distance and gravity
        d = max(settings->minimalDistance, distance(attractorLocation, particleLocation));
        g = settings->gravityFactor * a[j].mass / pow(d, settings->gravityExponent);
        
        // Computes unit vector
        float2 u = (attractorLocation - particleLocation) / d;
        
        // Computes gravity vector
        gVec += u * g;
    }
    
    // set g to final gravity, computed from gravity vector length
    g = distance(0, gVec);

    p[i].gravityVector = gVec;
    p[i].gravityPolarVector.x = g;
    p[i].gravityPolarVector.y = atan2(gVec.y, gVec.x);
    
    // If not locked or spring force < 1, update particle position by applying gravity force
    if (!settings->lockParticles && settings->spring < 1) {
        
        p[i].location.x += gVec.x * 100 / settings->width;
        p[i].location.y += gVec.y * 100 / settings->height;

        // If spring force > 9, compute spring attraction
        if (settings->spring > 0) {
            //F = k(p – p0)
            float d = distance(p[i].anchor, p[i].location);
            // Computes unit vector
            float2 u = (p[i].anchor - p[i].location) / d;
            p[i].location += u * d * settings->spring;
        }
        
    } else {
        // TODO: Remove an use fracional location
        p[i].location = p[i].anchor;
    }
}

