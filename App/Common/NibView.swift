//
//  NibView.swift
//  Gravitic
//
//  Created by Tristan Leblanc on 05/10/2020.
//  Copyright © 2020 Moose Factory Software. All rights reserved.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

protocol NibView { }

extension NibView where Self: MFView {
    
    static func load(in view: MFView?) -> Self {
        let nib = MFNib.load(nibNamed: String(describing: self), bundle: nil)
        
        
        #if os(macOS)
        var _objects: NSArray?
        nib.instantiate(withOwner: nil, topLevelObjects: &_objects)
        #else
        var _objects: [Any]?
        _objects = nib.instantiate(withOwner: nil, options: nil)
        #endif
        guard let objects = _objects,
            let loadedView = (objects.first { $0.self is Self }) as? Self else {
            fatalError()
        }
        
        if let stack = view as? MFStackView {
            stack.addArrangedSubview(loadedView)
        } else if view != nil {
            view!.addSubview(loadedView)
            loadedView.frame = view!.bounds
        }
        
        return loadedView
    }
}
