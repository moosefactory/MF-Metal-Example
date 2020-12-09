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

//  Dictionary+Getters.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 06/12/2020.

import Foundation

extension Dictionary where Key == String, Value == Any {
    
    func string(_ key: Key) -> String? {
        return self[key] as? String
    }
    
    func int(_ key: Key) -> Int? {
        return self[key] as? Int
    }
    
    func float(_ key: Key) -> Float? {
        return self[key] as? Float
    }
    
    func double(_ key: Key) -> Double? {
        return self[key] as? Double
    }

    func bool(_ key: Key) -> Bool? {
        return self[key] as? Bool
    }
    
    func dict(_ key: Key) -> Dictionary? {
        return self[key] as? Dictionary
    }
    
    func array<T>(_ key: Key) -> Array<T>? {
        return self[key] as? Array<T>
    }
    
    #if !os(watchOS)

    func cgFloat(_ key: Key) -> CGFloat? {
        return self[key] as? CGFloat
    }
    
    #endif
    
}
