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

//  Foundation+Extras.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 20/11/2020.

import Foundation

// MARK: - Variables matching

public extension String {

    func byReplacingVariables(_ variables: [String: String]) -> String {
        var out = self
        variables.forEach { key, value in
            out = out.replacingOccurrences(of: "{$\(key)}", with: value)
        }
        return out
    }

    /// Returns string without first character
    var byRemovingFirstCharacter: String {
        guard count > 1 else { return "" }
        return String(suffix(count-1))
    }
}

public extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}

public extension UUID {
    static var shortId: String { String(UUID().uuidString.prefix(4)) }
    static var uuid: String { UUID().uuidString }
}


//MARK: - String

public extension String {
    var ns: NSString {
        return NSString(string: self)
    }
    
    var byRemovingSpaces: String {
        replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\t", with: "")
    }
    
    var asRawDecimalNumberString: String {
        return filteringCharacters(in: CharacterSet(charactersIn: "0123456789.,")).replacingOccurrences(of: ",", with: ".")
    }

    var asRawIntegerNumberString: String {
        return filteringCharacters(in: CharacterSet(charactersIn: "0123456789"))
    }

    func filteringCharacters(in set: CharacterSet) -> String {
        guard !isEmpty else { return self }
        return String(unicodeScalars.filter { set.contains($0) })
    }
}

public extension URL {
    var ns: NSURL {
        return NSURL(fileURLWithPath: self.path)
    }
}
