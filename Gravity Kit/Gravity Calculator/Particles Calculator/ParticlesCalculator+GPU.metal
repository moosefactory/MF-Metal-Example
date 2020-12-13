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
    
    uint i = particlesGroupIndex * settings->numberOfParticlesPerThreadGroup + particleIndexInGroup;
    float2 particleLocation = p[i].planarLocation;
    
    // Updates anchor in view coordinates
    
    p[i].anchorInView = p[i].anchor * settings->radius;
    p[i].anchorInView.x += settings->width / 2;
    p[i].anchorInView.y += settings->height / 2;

    // Compute gravity force
    
    float g = 0;
    float d = 0;
    float2 gVec = 0;
    
    float n = settings->numberOfAttractors;
    
    // Iterates through attractors to compute gravity vector for particle
    
    for (uint j=0; j<n; j++) {
        float2 attractorLocation = a[j].planarLocation;

        // Compute distance and gravity
        d = max(settings->minimalDistance, 400 * distance(attractorLocation, particleLocation));
        g = settings->gravityFactor * a[j].mass / pow(d, settings->gravityExponent);
        
        // Computes unit vector
        float2 u = (attractorLocation - particleLocation) / d;
        
        // Computes gravity vector
        gVec += u * g;
    }
    
    // set g to final gravity, computed from gravity vector length
    g = distance(0, gVec) / settings->particlesSensitivity;

    p[i].gravityVector = gVec;
    p[i].gravityPolarVector.x = g;
    p[i].gravityPolarVector.y = atan2(gVec.y, gVec.x);
    
    // If not locked or spring force < 1, update particle position by applying gravity force
    if (!settings->lockParticles && settings->spring < 1) {
        
        p[i].planarLocation.x += gVec.x;
        p[i].planarLocation.y += gVec.y;

        // If spring force > 9, compute spring attraction
        if (settings->spring > 0) {
            //F = k(p – p0)
            float d = distance(p[i].anchor, p[i].planarLocation);
            // Computes unit vector
            float2 u = (p[i].anchor - p[i].planarLocation) / d;
            p[i].planarLocation += u * d * settings->spring;
            p[i].distanceToAnchor = d;
        }
        
    } else {
        // TODO: Remove an use fracional location
        p[i].planarLocation = p[i].anchor;
        p[i].distanceToAnchor = 0;
    }
    
    p[i].location = p[i].planarLocation * settings->radius;
    p[i].location.x += settings->width / 2;
    p[i].location.y += settings->height / 2;
}

