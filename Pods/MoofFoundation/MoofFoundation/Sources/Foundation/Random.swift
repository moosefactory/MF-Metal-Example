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

//  Random.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 19/11/2020.

import Foundation
import QuartzCore

#if !os(watchOS)

public extension CGFloat {
    
    /// Returns a  random value betwenn 0 and 1
    static func random() -> CGFloat {
        return CGFloat(Double(arc4random()) / Double(UInt32.max))
    }

    /// Returns a  random value betwenn 0 and 2π
    static func randomAngle() -> CGFloat {
        return CGFloat.pi * 2 * CGFloat(Double(arc4random()) / Double(UInt32.max))
    }

    /// Returns a random value betwenn -1 and 1
    static func signedRandom() -> CGFloat {
        return CGFloat( ((Double(arc4random()) / Double(UInt32.max)) - 0.5) * 2 )
    }

    /// Returns a random number between min and max
    static func random(min: CGFloat = 0, max: CGFloat = 1) -> CGFloat {
        let r = Double(arc4random()) / Double(UInt32.max)
        return min + CGFloat(r) * (max - min)
    }

    /// Returns a random number given a possible variation centered on median value
    static func random(median: CGFloat, variation: CGFloat) -> CGFloat {
        let r = Double(arc4random()) / Double(UInt32.max)
        return median + CGFloat(r) - variation / 2
    }

    /// Returns a random number given a possible variation based on a minimum value
    static func random(base: CGFloat, variation: CGFloat) -> CGFloat {
        return random(min: base, max: base + variation)
    }
}

#endif

public extension UInt8 {
    
    /// Returns a random UInt8 number
    static func random(min: UInt8 = 0, max: UInt8 = 255) -> UInt8 {
        let r = Double(arc4random()) / Double(UInt32.max)
        return min + UInt8(r * Double(max - min))
    }
}

public extension UInt16 {
    
    /// Returns a random UInt8 number
    static func random(min: UInt16 = 0, max: UInt16 = 65535) -> UInt16 {
        let r = Double(arc4random()) / Double(UInt32.max)
        return min + UInt16(r * Double(max - min))
    }
}

public extension Float {
    
    /// Returns a random float number
    static func random(min: Float = 0, max: Float = 1) -> Float {
        let x = Float(arc4random()) / Float(UInt32.max)
        return min + Float(x) * (max - min)
    }
}
