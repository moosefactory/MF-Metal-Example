//
//  GravityFieldCalculator.metal
//  Gravitic
//
//  Created by Tristan Leblanc on 22/11/2020.
//  Copyright © 2020 Moose Factory Software. All rights reserved.
//

#include <metal_stdlib>
#include "../Model/Model+GPU.metal"

kernel void computeGravityFields(texture2d<float, access::write> output [[texture(0)]],
                                 device const Group* group,
                                 device const Attractor* a,
                                 device const Environment* settings,
                                 uint2 gid [[thread_position_in_grid]])
{
    
    // The thread position in space
    float2 locationInSpace;
    locationInSpace.x = float(gid.x);
    locationInSpace.y = float(gid.y);
    
    // The particle position in space
    float g = 0;
    float d = 0;
    float2 gVec = 0;
    float4 color = 0;
    float n = settings->numberOfAttractors;
    
    for (uint i=0; i<n; i++) {
        float2 attractorLocation = a[i].location;

        // Compute distance and gravity
        d = max(settings->minimalDistance, distance(attractorLocation, locationInSpace));
        g = settings->gravityFactor * a[i].mass / pow(d, settings->gravityExponent);
        
        color += (a[i].color / n) / d;
        // Computes unit vector
        float2 u = (locationInSpace - attractorLocation) / d;
        
        // Computes gravity vector
        gVec += u * g;
    }
    
    // set g to final gravity, computed from gravity vector length
    g = distance(0, gVec);
    
    // We base our scale on a 2000 pixels circle
    float scale = 1000 / settings->radius;
    
    color.r = min(1.0f, (scale * 0.6 * ( color.r / g)));
    color.g = min(1.0f, (scale * 0.4 * ( color.g / g) * ( color.g / g)));
    color.b = 0;
    color.a = 1;
    output.write(color, gid);
}
