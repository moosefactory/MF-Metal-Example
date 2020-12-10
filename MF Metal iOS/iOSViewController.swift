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
    var particlesView: ParticlesView!

    var minDistance: CGFloat = 0
    var gExponent: CGFloat = 2.5
    var gScale: CGFloat = 1
    
    var needsUpdateSettings = true
    
    var splahStep: Int = 0
    
    let splashImages = ["HowTo", "HowTo2"]
    
    // The world, contains particles, attractors, and environment variables
    var world = World()
    
    // The world adapted to GPU - it basically holds raw buffers with world element,
    // and adds the notion of time and space ( Renderer size and frame index )
    lazy var worldBuffers: WorldBuffers = {
        return WorldBuffers(world: world, for: MTLCreateSystemDefaultDevice()!)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        world.numberOfParticles = 0
        
        // Creates the Metal view under the controls box
        mtkView = GraviFieldsView(frame: view.bounds, world: worldBuffers)
        view.addSubview(mtkView)
        view.layer.backgroundColor = CGColor(red: 0.08, green: 0.0, blue: 0.03, alpha: 1)
        mtkView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
        mtkView.renderedClosure = { frame in
            self.mtkView.isPaused = true
            self.particlesView?.update {
                
            }
            self.mtkView.isPaused = false
            self.world.updateFlag = []
        }
        
        makeParticlesView()
        
        randomize()
        
        self.view.addSubview(imageView)
        
        installGestures()
    }

    func installGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tap.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panned))
        view.addGestureRecognizer(pan)
        pan.delegate = self
    }
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        if sender.numberOfTouches == 2 {
            particlesView.isHidden = !particlesView.isHidden
            return
        }
        splahStep += 1
        if splahStep >= splashImages.count {
            imageView?.removeFromSuperview()
        } else {
            imageView?.image = UIImage(named: splashImages[splahStep])
        }
        randomize()
    }
    
    @IBAction func doubleTapped(_ sender: UITapGestureRecognizer) {
        mtkView.isHidden = !mtkView.isHidden
    }
    
    var previousPanValue: CGPoint?
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        previousPanValue = (gestureRecognizer as? UIPanGestureRecognizer)?.translation(in: mtkView)
        return true
    }
    

    @IBAction func panned(_ sender: UIPanGestureRecognizer) {
        let ty = (previousPanValue?.y ?? 0) - sender.translation(in: mtkView).y
        let tx = (previousPanValue?.x ?? 0) - sender.translation(in: mtkView).x

        print(tx)
        
        previousPanValue = sender.translation(in: mtkView)
        
        if tx > 10 {
            horizontalPan(right: true)
        }
        else if tx < -10 {
            horizontalPan(right: false)
        }

        switch sender.numberOfTouches {
            case 1:
                minDistance += ty / 10
                minDistance = max(0, min(400, minDistance))
            case 2:
                gExponent += ty  / 1000
                gExponent = max(2, min(4, gExponent))
            default:
                gScale += ty / 1000
                gScale = max(0.1, min(4, gScale))
        }
       updateSettings()
    }
    
    func horizontalPan(right: Bool) {
        if right {
            if world.numberOfParticles >= 1 {
                world.numberOfParticles -= 1
            } else {
                world.numberOfParticles = 0
            }
        } else {
            if world.numberOfParticles <= 40 {
                world.numberOfParticles += 1
            } else {
                world.numberOfParticles = 40
            }
        }
        
        particlesView.isHidden = world.numberOfParticles == 0
    }
    
    func updateSettings() {
       world.minimalDistance = minDistance
        world.gravityFactor = gScale
        world.gravityExponent = gExponent
    }

    /// Recreate random attractors
    func randomize() {
        world.complexity = Int.random(in: 1...10)
        world.randomize()
        needsUpdateSettings = true
    }

    func makeParticlesView() {
        // Creates the Particles view between the metal view and the controls box
        particlesView = ParticlesView(frame: view.bounds, world: worldBuffers)
        #if os(macOS)
        view.addSubview(particlesView, positioned: NSWindow.OrderingMode.below, relativeTo: controlBox)
        particlesView.autoresizingMask = [.width, .height]
        #else
        particlesView.isHidden = true
        view.addSubview(particlesView)
        #endif
    }

}

