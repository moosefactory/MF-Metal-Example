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

//  FileUtilities.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 21/11/2020.

import Foundation

public extension FileManager {
    
    /// A function to read dat in directories
    ///
    /// This function does not test any parameter and does nothing with nils
    func forEachDataInDirectory(url: URL?, closure: (URL, Data)->Void) {
        forEachFileInDirectory(url: url) { fileURL in
            if fileExists(atPath: fileURL.path), let data = try? Data(contentsOf: fileURL) {
                closure(fileURL, data)
            }
        }
    }
    
    /// A function to enumerate urls in directories
    ///
    func forEachFileInDirectory(url: URL?, closure: (URL)->Void) {
        guard let url = url, let fileURLs = try? contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) else {
            return
        }
        for fileURL in fileURLs {
            var isDir: ObjCBool = false
            if fileExists(atPath: fileURL.absoluteString, isDirectory: &isDir) {
                if !isDir.boolValue {
                    closure(fileURL)
                }
            }
        }
    }

    
    /// A function to read dat in directories
    ///
    /// This function does not test any parameter and does nothing with nils
    func forEachFolderInDirectory(url: URL?, closure: (URL)->Void) {
        guard let url = url, let fileURLs = try? contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) else {
            return
        }
        for fileURL in fileURLs {
            var isDir: ObjCBool = false
            if fileExists(atPath: fileURL.absoluteString, isDirectory: &isDir) {
                if !isDir.boolValue {
                    closure(fileURL)
                }
            }
        }
    }
}

//MARK: - File Wrappers Extensions

public extension FileWrapper {

    /// Adds a regular file wrapper to this wrapper
    
    func addFileWrapper(for name: String, with data: Data) -> FileWrapper {
        if let existingFileWrapper = fileWrappers?[name] {
            return existingFileWrapper
        }
        let fw = FileWrapper(regularFileWithContents: data)
        fw.preferredFilename = name
        addFileWrapper(fw)
        return fw
    }
    
    /// Adds a folder file wrapper to this wrapper
    ///
    /// It scans the directory url to add a regular file wrapper for each file inside.
    /// If recursive is true, it also creates wrappers for sub-folders
    
    func addFolderFileWrapper(for name: String, in directoryURL: URL) -> FileWrapper {
        if let existingFileWrapper = fileWrappers?[name] {
            return existingFileWrapper
        }
        let fm = FileManager.default
        var filesWrappers = [String: FileWrapper]()
        fm.forEachDataInDirectory(url: directoryURL) { url, data in
            let fileWrapper = FileWrapper(regularFileWithContents: data)
            filesWrappers[url.lastPathComponent] = fileWrapper
        }
        let fw = FileWrapper(directoryWithFileWrappers: filesWrappers)
        fw.preferredFilename = name
        addFileWrapper(fw)
        return fw
    }
}
