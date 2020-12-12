//
//  ViewController.swift
//  MF Metal iOS
//
//  Created by Tristan Leblanc on 08/12/2020.
//

import UIKit

class iOSViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var mtkView: GraviFieldsView!
    var particlesView: ParticlesView!

    @IBOutlet var uiContainer: UIStackView!
    
    var paramControlsBox: ActionsBox!
    @IBOutlet var selectedParameterView: ParameterUIView!

    @IBOutlet var fpsLabel: UILabel!
    @IBOutlet var attractorsLabel: UILabel!

    var timer: Timer?
    var chrono = Date()
    var fps: Double = 0

    var minDistance: CGFloat = 0
    var gExponent: CGFloat = 2.5
    var gScale: CGFloat = 1
    
    var needsUpdateSettings = true
    
    var splahStep: Int = 0
        
    // The world, contains particles, attractors, and environment variables
    var world = World()
    
    // The world adapted to GPU - it basically holds raw buffers with world element,
    // and adds the notion of time and space ( Renderer size and frame index )
    lazy var worldBuffers: WorldBuffers = {
        return WorldBuffers(world: world, for: MTLCreateSystemDefaultDevice()!)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        world.particlesGridSize = 0
        
        makeGravityFieldsView()
        makeParticlesView()
        
        loadControls()
        
        installGestures()
        
        uiContainer.contentScaleFactor = 0.3
        
        randomize()
    }

    func makeGravityFieldsView() {
        // Creates the Metal view under the controls box
        mtkView = GraviFieldsView(frame: view.bounds, world: worldBuffers)
        view.insertSubview(mtkView, belowSubview: uiContainer)
        mtkView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
        mtkView.renderedClosure = { frame in
            self.mtkView.isPaused = true
            self.particlesView?.update {
                
            }
            self.mtkView.isPaused = false
            self.world.updateFlag = []
        }
    }

    
    func makeParticlesView() {
        // Creates the Particles view between the metal view and the controls box
        particlesView = ParticlesView(frame: view.bounds, world: worldBuffers)
        particlesView.isHidden = true
        view.insertSubview(particlesView, belowSubview: uiContainer)
    }
    
    func installGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tap.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tap)
    }
 
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        paramControlsBox.isHidden = !paramControlsBox.isHidden
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

}

