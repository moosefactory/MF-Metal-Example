/*--------------------------------------------------------------------------*/
/*   /\/\/\__/\/\/\        MooseFactory Foundation - v2.0                   */
/*   \/\/\/..\/\/\/                                                         */
/*        |  |             (c)2007-2020 Tristan Leblanc                     */
/*        (oo)             tristan@moosefactory.eu                          */
/* MooseFactory Software                                                    */
/*--------------------------------------------------------------------------*/
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE. */
/*--------------------------------------------------------------------------*/

//  SIMD Utils.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 25/11/2020.

#if !os(watchOS)

import Foundation
import QuartzCore
import simd

#if os(macOS)
import Cocoa
#endif

// MARK: - Misc types and utilities

/// Returns a simd int from Int
public extension Int {
    var simd: simd_int1 { return simd_int1(self) }
}

/// Returns a simd float from CGFloat
public extension CGFloat {
    var simd: simd_float1 { return simd_float1(self) }
}

// MARK: - simd / CGPoint / CGSize utilities

public extension CGPoint {
    init(simd: simd_float2) {
        self.init(x: CGFloat(simd.x), y: CGFloat(simd.y))
    }
    
    var simd: simd_float2 {
        return simd_float2(Float(x), Float(y))
    }
}

public extension CGSize {
    init(simd: simd_float2) {
        self.init(width: CGFloat(simd.x), height: CGFloat(simd.y))
    }
    
    var simd: simd_float2 {
        return simd_float2(Float(width), Float(height))
    }
}

extension simd_float2 {
    var cgPoint: CGPoint { return CGPoint(x: CGFloat(self.x), y: CGFloat(self.y))}
    
    var cgSize: CGSize { return CGSize(width: CGFloat(self.x), height: CGFloat(self.y))}
}

// MARK: - simd / Color utilities

public extension CGColor {
    
    static func make(with simd: simd_float4, overrideAlpha: CGFloat? = nil) -> CGColor {
        return CGColor(srgbRed: CGFloat(simd.x), green: CGFloat(simd.y), blue: CGFloat(simd.z), alpha: overrideAlpha ?? CGFloat(simd.w))
    }
    
    var simd: simd_float4 {
        return color.simd
    }
}

#if os(macOS)

public extension NSColor {
    var simd: simd_float4 {
        return color.simd
    }
}
#endif

#endif
