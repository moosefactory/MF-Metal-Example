//
//  AttractorGroupsCalculator+GPU.metal
//  MF Metal Example
//
//  Created by Tristan Leblanc on 13/12/2020.
//

#include <metal_stdlib>
#include "../Model/Model+GPU.metal"

using namespace metal;

/// Compute the groups positions
///
/// This pass will compute all groups polar locations at current frame index
kernel void computeAttractorsGroupsLocations(device Group* g,
                                             device const Environment* settings,
                                             uint2 gid [[thread_position_in_grid]])
{
    Group group = g[0];
    g[0].scale = settings->scale;
    for (uint i=1;i<settings->numberOfGroups;i++) {
        Group superGroup = g[group.superGroupIndex];

        // rho
        g[i].polarLocation.x = g[i].anchor.x;
        // theta
        g[i].polarLocation.y = g[i].anchor.y + g[i].rotationSpeed * settings->frame;
        
        // local planar location
        float2 localPlanar;
        localPlanar.x = cos(g[i].polarLocation.y) * g[i].polarLocation.x;
        localPlanar.y = sin(g[i].polarLocation.y) * g[i].polarLocation.x;
    
        // Location in supergroup
        g[i].planarLocation = superGroup.planarLocation + localPlanar * superGroup.scale;

        g[i].location = g[i].planarLocation * settings->radius;
        g[i].location.x += settings->width / 2;
        g[i].location.y += settings->height / 2;
    }
}
