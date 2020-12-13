//
//  AttractorsCalculator.metal
//  MF Metal Example
//
//  Created by Tristan Leblanc on 13/12/2020.
//

#include <metal_stdlib>
#include "../Model/Model+GPU.metal"

using namespace metal;

kernel void computeAttractorsLocations(device Attractor* a,
                                       device const Group* g,
                                       device const Environment* settings,
                                       uint2 gid [[thread_position_in_grid]])
{
    // Convert the thread position in grid to attractor index in attractors buffer
    uint attractorIndexInGroup = float(gid.x);
    uint attractorsGroupIndex = float(gid.y);
    
    uint i = attractorsGroupIndex * settings->numberOfAttractorsPerThreadGroup + attractorIndexInGroup;

    Group group = g[a[i].groupIndex];
    
    // rho
    a[i].polarLocation.x = a[i].anchor.x;
    // theta
    a[i].polarLocation.y = a[i].anchor.y + a[i].rotationSpeed * settings->frame;
    
    // local planar location
    float2 localPlanar;
    localPlanar.x = cos(a[i].polarLocation.y) * a[i].polarLocation.x;
    localPlanar.y = sin(a[i].polarLocation.y) * a[i].polarLocation.x;

    // Location in supergroup
    a[i].planarLocation = group.planarLocation + localPlanar * group.scale * settings->scale;

    a[i].location = a[i].planarLocation * settings->radius;
    a[i].location.x += settings->width / 2;
    a[i].location.y += settings->height / 2;

}
