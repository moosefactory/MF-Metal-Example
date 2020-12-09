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

//  HTTPResponse.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 03/12/2020.

import Foundation

public struct HTTPResponse: Codable {
    
    /// The url where the error was triggered
    ///
    /// This is not necessarily the called url, it can give more detail on the script that did fail
    public private(set) var referer: String?
    
    /// The message sent by server
    public private(set) var message: String?

    /// The error message sent by server
    public private(set) var error: String?
    
    /// The HTTP Rest status code sent by server
    public private(set) var status: Int
    
    /// The API error code
    public private(set) var code: Int?

    /// The associated JSON data
    public private(set) var data: String?
    
    
    public var isError: Bool {
        return (status / 100) != 2
    }
    
    public static var badResponse: HTTPResponse {
        return HTTPResponse(referer: "Client",
                            message: "Wrong API response",
                            error: "Wrong API response",
                            status: -1, code: -1, data: nil)
    }
}

extension HTTPURLResponse {
    
    var apiHTTPResponse: HTTPResponse {
        if (self.statusCode / 100) == 2 {
            return HTTPResponse(referer: "Client",
                                message: "Success",
                                error: nil,
                                status: statusCode, code: -1, data: nil)
        } else {
            return HTTPResponse(referer: "Client",
                                message: "Error",
                                error: "Wrong API response",
                                status: statusCode, code: -1, data: nil)
        }
    }
}
