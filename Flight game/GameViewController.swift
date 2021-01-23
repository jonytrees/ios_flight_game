//
//  GameViewController.swift
//  Flight game
//
//  Created by Евгений Янушкевич on 21.01.2021.
//

//import UIKit
//import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    var scoreLabel = UILabel()
    
    var duration: TimeInterval = 10
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var scene: SCNScene {
        (self.view as! SCNView).scene!
    }
    
    var ship: SCNNode? {
        scene.rootNode.childNode(withName: "ship", recursively: true)
    }
    
    func addLabel() {
        scoreLabel.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 100)
        scoreLabel.numberOfLines = 2
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont.systemFont(ofSize: 30)
        scoreLabel.textColor = .white
        view.addSubview(scoreLabel)
        
        score = 0
    }
    
    func addShip(){
        
        let x = Int.random(in: -25...25)
        let y = Int.random(in: -25...25)
        let z = -105
        
        // set ship position
        ship?.position = SCNVector3(x, y, z)
        
        // remove ship animation
        ship?.removeAllActions()
        
        // set ship orientation
        ship?.look(at: SCNVector3(2 * x, 2 * y, 2 * z))
        
        // animate the 3d object
        ship?.runAction(SCNAction.move(to: SCNVector3(0, 0, 0), duration: duration)) {
            DispatchQueue.main.async {
                self.ship?.removeFromParentNode()
                self.scoreLabel.text = "Game Over\nScore: \(self.score)"
            }
        }
        
        duration *= 0.9
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        addLabel()
        addShip()
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                material.emission.contents = UIColor.black
                DispatchQueue.main.async {
                    self.addShip()
                }
                self.score += 1
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
