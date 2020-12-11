//
//  ActionsBox.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 11/12/2020.
//

import Foundation

import Cocoa

class ActionsBox: BoxStackView {
    
    var actionClosure: ((ActionIdentifierProtocol?, NSControl)->Void)?
    var actions = [ActionIdentifierProtocol]()
    
    @discardableResult static func load(in view: NSView, title: String = "",
                                        orientation: NSUserInterfaceLayoutOrientation = .vertical,
                                        with actions: [ActionIdentifierProtocol],
                                        actionClosure: @escaping (ActionIdentifierProtocol?, NSControl)->Void) -> ActionsBox {
        let box = ActionsBox.load(in: view, title: title)
        actions.forEach {
            let control = $0.makeControl(target: box, action: #selector(controlChanged))
            control.tag = $0.tag
            var title = $0.title
            if control is NSButton {
                title = ""
            }
            let controlBox = BoxStackView.loadWithControl(in: box.stack, title: title, with: control)
        }
        box.stack.orientation = orientation
        box.stack.setContentHuggingPriority(NSLayoutConstraint.Priority.required, for: .horizontal)
        box.actions = actions
        box.actionClosure = actionClosure
        return box
    }
    
    @objc func controlChanged(sender: NSControl) {
        let action = actions.with(tag: sender.tag)        
        actionClosure?(action, sender)
    }
}

extension BoxStackView {
    
    @discardableResult static func loadWithControl(in view: NSView, title: String = "",
                                        orientation: NSUserInterfaceLayoutOrientation = .horizontal,
                                        with control: NSControl) -> BoxStackView {
        let box = BoxStackView.load(in: view)
        box.stack.orientation = orientation
        box.stack.alignment = .centerY
        if !title.isEmpty {
            let label = NSTextField(labelWithString: title)
            box.stack.addArrangedSubview(label)
        }
        box.stack.addArrangedSubview(control)
//        box.stack.setContentHuggingPriority(NSLayoutConstraint.Priority.required, for: .horizontal)
        return box
    }
}
