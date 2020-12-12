//
//  MainViewController.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 12/12/2020.
//

import Foundation

#if os(macOS)

import Cocoa

typealias MainViewController = MacOSViewController

#else

import UIKit

typealias MainViewController = iOSViewController

extension UILabel {
    var stringValue: String? {
        get { text }
        set { text = newValue }
    }
}

#endif
