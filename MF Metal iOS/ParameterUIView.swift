//
//  ParameterUIView.swift
//  MF Metal iOS
//
//  Created by Tristan Leblanc on 12/12/2020.
//

import Foundation
import UIKit

class ParameterUIView: UIView {
    
    var setParameterAction: TypeErasedSetParameterActionProtocol? {
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
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var value: UILabel!
    
    var hideTimer: Timer?

    func update() {
        nameLabel.text = setParameterAction?.identifier.title ?? ""
        value.text = setParameterAction?.stringValue ?? ""
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        alpha = 0
        update()
    }
    
    func startHideTimer() {
        if hideTimer != nil {
            hideTimer?.invalidate()
        }
        hideTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(hide), userInfo: nil, repeats: false)
    }
    
    func show() {
        alpha = 1
    }

    
    @objc func hide() {
        alpha = 0
    }

}
