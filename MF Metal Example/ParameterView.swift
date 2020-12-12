//
//  ParameterView.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 11/12/2020.
//

import Foundation
import Cocoa

class ParameterView: ActionsBox {
    
    var setParameterAction: TypeErasedParameterProtocol? {
        didSet {
            update()
            if setParameterAction != nil {
                show()
            } else {
                hide()
            }
            startHideTimer()
        }
    }
    
    @IBOutlet var nameLabel: NSTextField!
    @IBOutlet var value: NSTextField!
    
    var hideTimer: Timer?
    
    func update() {
        nameLabel.stringValue = setParameterAction?.identifier.title ?? ""
        value.stringValue = setParameterAction?.stringValue ?? ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.borderWidth = 2
        self.cornerRadius = 5
        self.borderColor = NSColor.white
        alphaValue = 0
        update()
    }
    
    func startHideTimer() {
        if hideTimer != nil {
            hideTimer?.invalidate()
        }
        hideTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(hide), userInfo: nil, repeats: false)
    }
    
    func show() {
        NSAnimationContext.runAnimationGroup({_ in
            NSAnimationContext.current.duration = 0.5
            animator().alphaValue = 1
        }, completionHandler:{
        })
    }

    
    @objc func hide() {
        NSAnimationContext.runAnimationGroup({_ in
            NSAnimationContext.current.duration = 4.0
            animator().alphaValue = 0
        }, completionHandler:{
        })
    }
}
