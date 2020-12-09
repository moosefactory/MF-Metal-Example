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

//  CGPolarPoint.swift
//  Gravitic
//
//  Created by Tristan Leblanc on 25/09/2020.

#if !os(watchOS)

import Foundation
import QuartzCore

public struct PolarPoint: Codable {
    public var rho: CGFloat = 0
    public var theta: CGFloat = 0
    
    public static let zero = PolarPoint(rho: 0, theta: 0)
    
    enum CodingKeys: String, CodingKey {
        case rho
        case theta
    }
    
    public init(rho: CGFloat, theta: CGFloat) {
        self.rho = rho
        self.theta = theta
    }
    
    public var toRectangular: CGPoint {
        return CGPoint(x: cos(theta) * rho, y: sin(theta) * rho)
    }
    
    public func toRectangular(in rect: CGRect) -> CGPoint {
        let c = rect.boundsCenter
        return CGPoint(x: cos(theta) * rho, y: sin(theta) * rho) + c
    }
    
    public func fractionnalToRectangular(in rect: CGRect) -> CGPoint {
        let w = rect.width / 2
        let h = rect.height / 2
        let c = rect.boundsCenter
        return CGPoint(x: cos(theta) * rho * w, y: sin(theta) * rho * h) + c
    }

    /// Divide polar vector length by a real number
    public static func / (lhs: PolarPoint, rhs: CGFloat) -> PolarPoint {
        return PolarPoint(rho: lhs.rho / rhs, theta: lhs.theta)
    }
    
    public func rotated(by angle: CGFloat) -> PolarPoint {
        return PolarPoint(rho: rho, theta: theta + angle)
    }
}

extension PolarPoint: CustomStringConvertible {
    public var description: String {
        return "(ρ:\(rho) θ:\(theta))"
    }
    
    public var dec3: String {
        return "(ρ:\(rho.dec3) θ:\(theta.dec3))"
    }
}

public extension CGPoint {
    var toPolar: PolarPoint {
        return PolarPoint(rho: sqrt( x * x + y * y), theta: atan2(x, y) )
    }
    
    func toFractionnalPolar(in rect: CGRect) -> PolarPoint {
        let fx = x / (rect.width / 2)
        let fy = y / (rect.height / 2)
        
        return PolarPoint(rho: sqrt( fx * fx + fy * fy), theta: atan2(x, y) )
    }
}

#endif
