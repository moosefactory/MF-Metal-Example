//
//  BoxStackView.swift
//  Gravitic
//
//  Created by Tristan Leblanc on 05/10/2020.
//  Copyright © 2020 Moose Factory Software. All rights reserved.
//

import Foundation
import Cocoa

protocol LoadableFromNib : NSView {
    
}

extension LoadableFromNib {
    
    static func load(in view: NSView?) -> Self {
        guard let nib = NSNib(nibNamed: String(describing: self), bundle: nil) else {
            fatalError()
        }
        
        var _objects: NSArray?
        
        nib.instantiate(withOwner: nil, topLevelObjects: &_objects)
        guard let objects = _objects,
            let loadedView = (objects.first { $0.self is Self }) as? Self else {
            fatalError()
        }
        
        if let stack = view as? NSStackView {
            stack.addArrangedSubview(loadedView)
        } else if view != nil {
            view!.addSubview(loadedView)
            loadedView.frame = view!.bounds
        }
        
        return loadedView
    }
}

class BoxStackView: NSBox, LoadableFromNib {
    @IBOutlet weak var stack: NSStackView!

    static func load(in view: NSView, title: String,
                     orientation: NSUserInterfaceLayoutOrientation = .vertical) -> Self {
        let loadedView = Self.load(in: view)

        loadedView.title = title
        loadedView.titlePosition = .noTitle
        loadedView.stack.orientation = orientation
        return loadedView
    }
}
