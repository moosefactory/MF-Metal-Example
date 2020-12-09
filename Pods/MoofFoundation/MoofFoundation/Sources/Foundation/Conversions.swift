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

//  Conversions.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 20/11/2020.

#if !os(watchOS)

import Foundation
import QuartzCore

// MARK: Fractional conversions

public extension CGPoint {
    /// Returns a point in positive fractional format
    /// (0,0) is bottom left corner
    /// (1,1) is top right corner
    func toPositiveFractional(in rect: CGRect) -> CGPoint {
        return CGPoint(x: (x - rect.minX) / rect.width, y: (y - rect.minY) / rect.height)
    }

    func fromPositiveFractional(in rect: CGRect) -> CGPoint {
        return CGPoint(x: x * rect.width + rect.minX, y: y * rect.height + rect.minY)
    }

    /// Returns a point in fractional format
    /// (0,0) is center
    /// (1,1) is top right corner
    /// (-1,-1) is bottom left corner
    func toFractional(in rect: CGRect) -> CGPoint {
        return CGPoint(x: (x - rect.frameCenter.x) / (rect.width / 2), y: (y - rect.frameCenter.y) / (rect.height / 2))
    }

    func fromFractional(in rect: CGRect) -> CGPoint {
        return CGPoint(x: (x * rect.width / 2) + rect.frameCenter.x, y: (y * rect.height / 2) + rect.frameCenter.y)
    }
    
    func clampToFractional() -> CGPoint {
        return CGPoint(x: x.clampToFractional, y: y.clampToFractional)
    }
    
    func clampToPositiveFractional() -> CGPoint {
        return CGPoint(x: x.clampToPositiveFractional, y: y.clampToPositiveFractional)
    }
}

public extension CGFloat {
    var toFractionnal: CGFloat { return self / 100 }
    var fromFractionnal: CGFloat { return self * 100 }
    
    func clamp(_ _min: CGFloat, _ _max: CGFloat) -> CGFloat {
        return Swift.max(_min, Swift.min(_max, self))
    }
    
    var clampToPositiveFractional: CGFloat {
        return Swift.max(CGFloat(0), Swift.min(CGFloat(1), self))
    }
    
    var clampToFractional: CGFloat {
        return Swift.max(CGFloat(-1), Swift.min(CGFloat(1), self))
    }
    
    func bary(to: CGFloat, fraction: CGFloat = 0.5) -> CGFloat {
        let f = fraction.clampToPositiveFractional
        return self * (1 - f) + to * f
    }
}

// MARK: Degrees / radians conversions

public extension CGFloat {
    static let degToRadFactor = CGFloat.pi / 180
    var degreeToRadian: CGFloat { return self * CGFloat.degToRadFactor }
    var radianToDegree: CGFloat { return self / CGFloat.degToRadFactor }
}

public extension Float {
    static let degToRadFactor = Float.pi / 180
    var degreeToRadian: Float { return self * Float.degToRadFactor }
    var radianToDegree: Float { return self / Float.degToRadFactor }
}

#endif
