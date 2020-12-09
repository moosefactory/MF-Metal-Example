//
//  Model.metal
//  Gravitic
//
//  Created by Tristan Leblanc on 22/11/2020.
//  Copyright © 2020 Moose Factory Software. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Group {
    int index;
    int superGroupIndex;
    float2 location;
    float rotationSpeed;
    float scale;
};

struct Attractor {
    int groupIndex;

    float2 location;
    float rotationSpeed;
    
    float mass;
    float4 color;
};

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
    
    // Our environment settings
    float minimalDistance;
    float gravityFactor;
    float gravityExponent;
};
