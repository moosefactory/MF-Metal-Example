//
//  ViewController.swift
//  MF Metal iOS
//
//  Created by Tristan Leblanc on 08/12/2020.
//

import UIKit

class iOSViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var imageView: UIImageView!
    
    var mtkView: GraviFieldsView!

    var minDistance: CGFloat = 0
    var gExponent: CGFloat = 2.5
    var gScale: CGFloat = 1
    
    var needsUpdateSettings = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Creates the Metal view under the controls box
        mtkView = GraviFieldsView( frame: view.bounds, device: MTLCreateSystemDefaultDevice()!)
        view.addSubview(mtkView)
        view.layer.backgroundColor = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
        mtkView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        mtkView.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panned))
        mtkView.addGestureRecognizer(pan)
        
        mtkView.renderedClosure = { frame in
            if self.needsUpdateSettings {
                self.updateSettings()
                self.needsUpdateSettings = false
            }
        }
        
        pan.delegate = self
        randomize()
        
        self.view.addSubview(imageView)
    }

    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        imageView?.isHidden = true
        randomize()
    }

    var previousPanValue: CGFloat?
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        previousPanValue = (gestureRecognizer as? UIPanGestureRecognizer)?.translation(in: mtkView).y
        return true
    }
    
    @IBAction func panned(_ sender: UIPanGestureRecognizer) {
        let ty = sender.translation(in: mtkView).y
        let t = (previousPanValue ?? 0) - ty
        previousPanValue = ty
        switch sender.numberOfTouches {
            case 1:
                minDistance += t / 10
                minDistance = max(0, min(400, minDistance))
            case 2:
                gExponent += t  / 1000
                gExponent = max(2, min(4, gExponent))
            default:
                gScale += t / 1000
                gScale = max(0.1, min(4, gScale))
        }
        needsUpdateSettings = true
    }
    
    func updateSettings() {
        mtkView.calculator?.minimalDistance = minDistance
        mtkView.calculator?.gravityFactor = gScale
        mtkView.calculator?.gravityExponent = gExponent
    }

    /// Recreate random attractors
    func randomize() {
        mtkView.makeWorld()
        needsUpdateSettings = true
    }

}

