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

//  Point.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 25/11/2020.

#if !os(watchOS)

import Foundation
import QuartzCore
#if os(macOS)
import Cocoa
#endif
import simd

/// Float point, to use in swift/metal models

public struct Point: Codable {
    public var x: Float = 0
    public var y: Float = 0
    
    public static let zero = Point(x: 0, y: 0)
    
    enum CodingKeys: String, CodingKey {
        case x
        case y
    }
    
    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
    
    public var cgPoint: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}

extension Point {
    public var simd: simd_float2 { return simd_float2(x, y)}
    
    #if os(macOS)
    var ns: NSPoint { NSPoint(simd: simd) }
    #endif
    var cg: CGPoint { CGPoint(simd: simd) }
}

public extension CGPoint {
    var point: Point {
        return Point(x: Float(x), y: Float(y))
    }
}

#endif
