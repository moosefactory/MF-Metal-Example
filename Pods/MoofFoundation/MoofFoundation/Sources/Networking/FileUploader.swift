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

//  FileUploader.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 27/11/2020.

import Foundation

public class FileUploader {
    let boundary = "Boundary-\(UUID().uuidString)"
    var request: URLRequest
    
    lazy var session: URLSession = {
        URLSession(configuration: URLSessionConfiguration.default)
    }()

    public init(url: URL, fileURL: URL) {
        self.request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = getHTTPBody(parameters: [:],
                                       fileName: fileURL.lastPathComponent,
                                       fileType: "image/jpg",
                                       url: fileURL)
    }
    
    func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        var data = Data()
        
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        
        return data as Data
    }
    
    func convertFormField(named name: String, value: String, using boundary: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        
        return fieldString
    }
    
    
    func getHTTPBody(parameters: [String: String] = [:], fileName: String, fileType: String, url: URL) -> Data? {
        var httpBody = Data()
        
        for (key, value) in parameters {
            httpBody.appendString(convertFormField(named: key, value: value, using: boundary))
        }
        
        do {
            let fileData = try Data(contentsOf: url)
            httpBody.append(convertFileData(fieldName: "file",
                                            fileName: fileName,
                                            mimeType: fileType,
                                            fileData: fileData,
                                            using: boundary))
            
            httpBody.appendString("--\(boundary)--")
            
            return httpBody
        }
        catch {
            return nil
        }
    }
    
    // MARK: - Upload Task
    
    func run(completion: @escaping (HTTPResponse)->Void) {
        let request = self.request
        let task = session.dataTask(with: request) {(data, response, error) in
            guard let data = data, let apiResponse = try? JSONDecoder().decode(HTTPResponse.self, from: data) else {
                completion((response as? HTTPURLResponse)?.apiHTTPResponse ?? HTTPResponse.badResponse)
                return
            }
            completion(apiResponse)
        }
        task.resume()
    }
    
    public static func uploadFromFolder(base: String, from folder: URL, to url: URL, completion: @escaping (HTTPResponse)->Void) {
                
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(atPath: folder.path)
            
            fileURLs.compactMap({ folder.appendingPathComponent($0) }).forEach {
                let fileUploader = FileUploader(url: url, fileURL: $0)
                fileUploader.run(completion: completion)
            }
        } catch {
            return
        }
        
    }

}
