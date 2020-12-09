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

//  KeyPathIterable.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 06/12/2020.

import Foundation
import Combine

// MARK: - Mirror convenience extension

extension Mirror {
    
    /// Iterates through all children
    static func forEachProperty(of object: Any, doClosure: (String, Any)->Void) {
        for (property, value) in Mirror(reflecting: object).children where property != nil {
            doClosure(property!, value)
        }
    }
    
    /// Executes closure if property named 'property' is found
    ///
    /// Returns true if property was found
    @discardableResult static func withProperty(_ property: String, of object: Any, doClosure: (String, Any)->Void) -> Bool {
        for (property, value) in Mirror(reflecting: object).children where property == property {
            doClosure(property!, value)
            return true
        }
        return false
    }
    
    /// Utility function to determine if a value is marked @Published
    static func isValuePublished(_ value: Any) -> Bool {
        let valueTypeAsString = String(describing: type(of: value))
        let prefix = valueTypeAsString.prefix { $0 != "<" }
        return prefix == "Published"
    }
    
    static func isClass(_ value: Any) -> Bool {
        return (type(of: value) as? AnyClass) != nil
    }
}

// MARK: - Mirror extension to return any object properties as [Property, Value] dictionary

/// Options used to set iteration behavior
struct KeyPathIterationOptions: OptionSet {
    var rawValue: Int = 0
    
    static let none = KeyPathIterationOptions()
    
    /// .goDeep will enumerates properties as sub dictionaries if they conform to KeyPathIterable protocol
    static let goDeep = KeyPathIterationOptions(rawValue: 0x01)
    
    /// .explodeStructs returns properties as keypaths dictionary if they are structs
    /// for example, a CGPoint will be returned as ["x": CGFloat, "y": CGFloat]
    static let explodeStructs = KeyPathIterationOptions(rawValue: 0x04)
    
    /// .explodeClasses returns properties as keypaths dictionary if they are classes
    static let explodeClasses = KeyPathIterationOptions(rawValue: 0x08)
    
    /// .explode combine all options above.
    /// It will enumerates all kind of properties, as deep as possible
    static let explode: KeyPathIterationOptions = [.goDeep, .explodeStructs, .explodeClasses]
    
    /// .raw will returns properties as they are declared
    ///
    /// This implies @Published properties will be returned as Published<> values
    ///
    /// Without raw, @Published properties will be replaced by their real property name and value
    static let raw = KeyPathIterationOptions(rawValue: 0x10)
}

extension Mirror {
    
    /// Returns objects properties as a dictionary [property: value]
    ///
    /// Possible options are:
    /// - .goDeep : Also parse sub objects if they conform to KeyPathIterable protocol
    static func allKeyPaths(for object: Any, options: KeyPathIterationOptions = .none) -> [String: Any] {
        var out = [String: Any]()
        
        // Returns value to add to output dictionary for given property
        func getProps(value: Any, with options: KeyPathIterationOptions) -> Any {
            let isClass = Mirror.isClass(value)
            // If .goDeep is set and we have a KeyPathIterable, returns enumerated keyPaths
            // else we check for other options
            var explode = options.contains(.goDeep) && value as? KeyPathIterable != nil
            if !explode {
                explode = isClass ? options.contains(.explodeClasses) : options.contains(.explodeStructs)
            }
            guard explode else { return value }
            
            let keyPaths = allKeyPaths(for: value, options: options)
            return keyPaths.isEmpty ? value : keyPaths
        }
        
        Mirror.forEachProperty(of: object) { property, value in
            // If value is of type Published<Some>, we transform to 'regular' property label and value
            // ( unless the .raw value is set )
            if Self.isValuePublished(value) {
                if !options.contains(.raw) {
                    Mirror.withProperty("value", of: value) { _, subValue in
                        out[property.byRemovingFirstCharacter] = getProps(value: subValue, with: options)
                    }
                }
                    // If .raw, we send publisher, or publisher properties if .explode is set
                else {
                    out[property.byRemovingFirstCharacter] = getProps(value: value, with: options)
                }
            } else {
                out[property] = getProps(value: value, with: options)
            }
        }
        return out
    }
}

// MARK: - KeyPathIterable

protocol KeyPathIterable {
    
}

extension KeyPathIterable {
    
    /// Returns all object properties
    var allKeyPaths: [String: Any] {
        return Mirror.allKeyPaths(for: self, options: .none)
    }
    
    /// Returns all object properties
    /// Options:
    /// - .goDeep : return KeyPathIterable sub properties as sub dictionaries
    /// - .explodeTypes : return all sub propeties as dictionaries
    /// - .raw : Don't replace @Published properties by their value
    
    func allKeyPaths(options: KeyPathIterationOptions = .none) -> [String: Any] {
        return Mirror.allKeyPaths(for: self, options: options)
    }
}
