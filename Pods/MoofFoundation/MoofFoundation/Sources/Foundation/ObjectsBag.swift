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

//  ObjectsBag.swift
//  CombineModel
//
//  Created by Tristan Leblanc on 06/12/2020.

import Foundation

struct Multiple: Equatable, CustomStringConvertible {
    static func == (lhs: Self, rhs: Self) -> Bool { return false }
    
    var description: String { return "<Multiple>" }
}

class ObjectsBag {
    
    var objects: [Any]
    var objectsKeyPaths: [[String: Any]]
    
    var representingKeyPaths: [String: Any]? {
        guard var out = objectsKeyPaths.first else {
            return nil
        }
        if objectsKeyPaths.count == 1 {
            return out
        }
        
        let dicts = Array(objectsKeyPaths.dropFirst())

        for dict in dicts {
            deepMerge(dict, to: &out)
        }
        return out
    }
    
    func deepMerge(_ dict: [String: Any], to out: inout [String: Any]) {
        out.merge(dict) { (l, r) in
            guard type(of: l) == type(of: r) else {
                return Multiple()
            }
            
            if var lo = l as? [String: Any], let ro = r as? [String: Any] {
                if lo.count == ro.count {
                    self.deepMerge(ro, to: &lo)
                    return lo
                } else {
                    return Multiple()
                }
            }

            if let lo = l as? [AnyObject], let ro = r as? [AnyObject] {
                if lo.count == ro.count {
                    for obj in lo.enumerated() {
                        if !compareBytes(lhs: obj.element, rhs: ro[obj.offset]) {
                            return Multiple()
                        }
                    }
                    return l
                } else {
                    return Multiple()
                }
            }

            if let lo = l as? AnyObject, let ro = r as? AnyObject {
                if compareBytes(lhs: lo, rhs: ro) {
                    return l
                }
            }
            
            return Multiple()
        }
    }

    func compareBytes(lhs: AnyObject, rhs: AnyObject) -> Bool {
        let lptr = Unmanaged.passUnretained(lhs).toOpaque()
        let rptr = Unmanaged.passUnretained(rhs).toOpaque()
        return lptr == rptr
    }

    init(_ objects: [Any]) {
        self.objects = objects
        self.objectsKeyPaths  = objects.map { Mirror.allKeyPaths(for: $0, options: .explode)}
    }
}
