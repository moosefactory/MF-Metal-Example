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

//  CGComplex.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 19/11/2020.

#if !os(watchOS)

import Foundation
import QuartzCore

public struct CGComplex {
    public var a: CGFloat
    public var b: CGFloat
    
    public init(a: CGFloat, b: CGFloat) {
        self.a = a
        self.b = b
    }
    
    public static let zero = CGComplex(a: 0, b: 0)
    
    public static func + (lhs: CGComplex, rhs: CGComplex) -> CGComplex {
        return CGComplex(a: lhs.a + rhs.a, b: lhs.b + rhs.b)
    }
    
    public static func - (lhs: CGComplex, rhs: CGComplex) -> CGComplex {
        return CGComplex(a: lhs.a - rhs.a, b: lhs.b - rhs.b)
    }

    public static func * (lhs: CGComplex, rhs: CGComplex) -> CGComplex {
        return CGComplex(a: lhs.a * rhs.a - lhs.b * rhs.b, b: lhs.a * rhs.b + lhs.b * rhs.a)
    }

    public var abs: CGFloat {
        return sqrt(a * a + b * b)
    }
    
    var vector: CGVector {
        return CGVector(dx: a, dy: b)
    }
    
}

extension CGComplex: CustomStringConvertible {
    public var description: String {
        return b >= 0 ? "(\(a)+\(b)i)" : "(\(a)-\(-b)i)"
    }
}

extension CGVector {
    public var complex: CGComplex { return CGComplex(a: dx, b: dy) }
}

#endif
