/*
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import SceneKit
import AVFoundation
import CoreLocation
import PokemonAPI

class ViewController: UIViewController {
  
  @IBOutlet weak var sceneView: SCNView!
  @IBOutlet weak var leftIndicator: UILabel!
  @IBOutlet weak var rightIndicator: UILabel!
  
  @IBOutlet var move1Button: UIButton!
  @IBOutlet var move2Button: UIButton!
  @IBOutlet var move3Button: UIButton!
  @IBOutlet var move4Button: UIButton!
  
  @IBOutlet var enemyLabel: UILabel!
  @IBOutlet var friendLabel: UILabel!
  @IBOutlet var menuTextView: UITextView!
  
  var cameraSession: AVCaptureSession?
  var cameraLayer: AVCaptureVideoPreviewLayer?
  var target: ARItem!
  
  var locationManager = CLLocationManager()
  var heading: Double = 0
  var userLocation = CLLocation()
  
  var semaphore = DispatchSemaphore(value: 0)
  
  let scene = SCNScene()
  let cameraNode = SCNNode()
  let targetNode = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0))
  
  var battle: Battle!
  var friendMoves: [PKMMove]!
  var friend = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0))
  
  var delegate: ARControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //self.automaticallyAdjustsScrollViewInsets = false
    menuTextView.contentInsetAdjustmentBehavior = .never
    menuTextView.textColor = .black
    menuTextView.backgroundColor = .white
    
    loadCamera()
    self.cameraSession?.startRunning()
    
    self.locationManager.delegate = self
    self.locationManager.startUpdatingHeading()
    
    sceneView.scene = scene
    cameraNode.camera = SCNCamera()
    cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
    scene.rootNode.addChildNode(cameraNode)
    setupFriend()
    setupTarget()
    
    updateLabels()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    menuTextView.isHidden = true
    turnOnButtons()
  }
  
  private func updateLabels() {
    enemyLabel.text = "Lv: \(battle.getEnemy().getLevel()) Hp: \(battle.getEnemy().getCurrentHealth())/\(battle.getEnemy().getMaxHealth())"
    friendLabel.text = "Lv: \(battle.getFriend().getLevel()) Hp: \(battle.getFriend().getCurrentHealth())/\(battle.getFriend().getMaxHealth())"
  }
  
  @IBAction func button1Pressed(_ sender: Any) {
    executeTurn(move: friendMoves[0])
  }
  
  @IBAction func button2Pressed(_ sender: Any) {
    executeTurn(move: friendMoves[1])
  }
  
  @IBAction func button3Pressed(_ sender: Any) {
    executeTurn(move: friendMoves[2])
  }
  
  @IBAction func button4Pressed(_ sender: Any) {
    executeTurn(move: friendMoves[3])
  }
  
  private func turnOnButtons() {
    
    menuTextView.isHidden = true
    
    move1Button.isHidden = false
    move2Button.isHidden = false
    move3Button.isHidden = false
    move4Button.isHidden = false
    
    friendMoves = battle.getFriend().getCurrMoves()
    move1Button.setTitle(friendMoves[0].name!, for: .normal)
    if (friendMoves.count > 1) {
      move2Button.setTitle(friendMoves[1].name!, for: .normal)
    } else {
      move2Button.isHidden = true
    }
    if (friendMoves.count > 2) {
      move3Button.setTitle(friendMoves[2].name!, for: .normal)
    } else {
      move3Button.isHidden = true
    }
    if (friendMoves.count > 3) {
      move4Button.setTitle(friendMoves[3].name!, for: .normal)
    } else {
      move4Button.isHidden = true
    }
  }
  
  private func turnOffButtons() {
    
    move1Button.titleLabel!.text = ""
    move2Button.titleLabel!.text = ""
    move3Button.titleLabel!.text = ""
    move4Button.titleLabel!.text = ""
    
    move1Button.isHidden = true
    move2Button.isHidden = true
    move3Button.isHidden = true
    move4Button.isHidden = true
    
    menuTextView.isHidden = false
    menuTextView.text = "bruhasdasdashjdfjasdhfjsadfasjhfsa"
    print("end of turn off ")
  }
  
  private func executeTurn(move: PKMMove) {
    semaphore = DispatchSemaphore(value: 0)
    turnOffButtons()
    print("buttons off")
    semaphore.wait()
    semaphore = DispatchSemaphore(value: 0)
    if battle.doIMoveFirst() {
      DispatchQueue.main.async {
        self.friendMove(move: move)
      }
    }
    DispatchQueue.main.async {
      self.enemyMove()
    }
    if !battle.doIMoveFirst() {
      DispatchQueue.main.async {
        self.friendMove(move: move)
      }
    }
    turnOnButtons()
    print("buttons on")
  }
  
  private func friendMove(move: PKMMove) {
    battle.friendTurn(move: move)
    menuTextView.isHidden = false
    menuTextView.text = "\(battle.getFriend().getModel().name!) used \(move.name!)!"
    print(menuTextView.text!)
    menuTextView.isHidden = false
    battle.timer(seconds: 2)
    updateLabels()
    battle.timer(seconds: 2)
    if battle.getEnemy().getCurrentHealth() == 0 {
      menuTextView.text = "\(battle.getEnemy().getModel().name!) fainted!"
      print(menuTextView.text!)
      battle.timer(seconds: 4)
      let leveledUp = battle.getFriend().addExp(exp: battle.getEnemy().getModel().baseExperience!)
      updateLabels()
      menuTextView.text = "\(battle.getFriend().getModel().name!) gained \(battle.getEnemy().getModel().baseExperience!) exp!"
      print(menuTextView.text!)
      battle.timer(seconds: 3)
      if leveledUp {
        menuTextView.text = "\(battle.getFriend().getModel().name!) leveled up!"
        print(menuTextView.text!)
        battle.timer(seconds: 3)
      }
      if let trainer = battle.getOpponent() {
        if trainer.nextPokemon() != nil {
          battle.setEnemy(next: trainer.nextPokemon()!)
        } else {
          victory()
        }
      } else {
        victory()
      }
    }
  }
  
  private func enemyMove() {
    let move = battle.enemyTurn()
    menuTextView.isHidden = false
    menuTextView.text = "\(battle.getEnemy().getModel().name!) used \(move.name!)!"
    print(menuTextView.text!)
    menuTextView.isHidden = false
    battle.timer(seconds: 2)
    updateLabels()
    battle.timer(seconds: 2)
    if battle.getFriend().getCurrentHealth() == 0 {
      menuTextView.text = "\(battle.getFriend().getModel().name!) fainted!"
      print(menuTextView.text!)
      battle.timer(seconds: 4)
      if User.getTrainer().nextPokemon() != nil {
        battle.setFriend(next: User.getTrainer().nextPokemon()!)
      } else {
        defeat()
      }
    }
  }
  
  private func victory() {
    
  }
  
  private func defeat() {
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func loadCamera() {
    let captureSessionResult = createCaptureSession()
    
    guard captureSessionResult.error == nil else {
      print("Error creating capture session.")
      return
    }
    
    self.cameraSession = captureSessionResult.session!
    
    let cameraLayer = AVCaptureVideoPreviewLayer(session: self.cameraSession!)
    cameraLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    cameraLayer.frame = self.view.bounds
      
    self.view.layer.insertSublayer(cameraLayer, at: 0)
    self.cameraLayer = cameraLayer
  }
  
  func createCaptureSession() -> (session: AVCaptureSession?, error: NSError?) {
    var error: NSError?
    var captureSession: AVCaptureSession?
    
    let backVideoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
    
    if backVideoDevice != nil {
      var videoInput: AVCaptureDeviceInput!
      do {
        videoInput = try AVCaptureDeviceInput(device: backVideoDevice!)
      } catch let error1 as NSError {
        error = error1
        videoInput = nil
      }
      
      if error == nil {
        captureSession = AVCaptureSession()
        
        if captureSession!.canAddInput(videoInput) {
          captureSession!.addInput(videoInput)
        } else {
          error = NSError(domain: "", code: 0, userInfo: ["description": "Error adding video input."])
        }
        
      } else {
        error = NSError(domain: "", code: 1, userInfo: ["description": "Error creating capture device input."])
      }
      
    } else {
      error = NSError(domain: "", code: 2, userInfo: ["description": "Back video device not found."])
    }
    
    return (session: captureSession, error: error)
  }
  
  func radiansToDegrees(_ radians: Double) -> Double {
    return (radians) * (180.0 / .pi)
  }
  
  func degreesToRadians(_ degrees: Double) -> Double {
    return (degrees) * (.pi / 180.0)
  }
  
  func getHeadingForDirectionFromCoordinate(from: CLLocation, to: CLLocation) -> Double {
    let fLat = degreesToRadians(from.coordinate.latitude)
    let fLng = degreesToRadians(from.coordinate.longitude)
    let tLat = degreesToRadians(to.coordinate.latitude)
    let tLng = degreesToRadians(to.coordinate.longitude)
    
    let degree = radiansToDegrees(atan2(sin(tLng - fLng) * cos(tLat), cos(fLat) * sin(tLat) - sin(fLat) * cos(tLat) * cos(tLng - fLng)))
    
    if degree >= 0 {
      return degree
    } else {
      return degree + 360
    }
  }
  
  func setupTarget() {
    //let scene = SCNScene(named: "art.scnassets/\(target.itemDescription).dae")
    let scene = SCNScene(named: "art.scnassets/Pokemon_Models/\(target.itemDescription)/\(target.itemDescription).dae")
    //let enemy = scene?.rootNode.childNode(withName: target.itemDescription, recursively: true)
    let enemy = scene?.rootNode
    
    let scale = 0.6
    enemy?.scale = SCNVector3(scale, scale, scale)
    enemy?.position = SCNVector3(0, 20, -20)
    friend.addChildNode(enemy!)
    enemy?.localTranslate(by: SCNVector3(0, 80, 0))
    enemy?.look(at: SCNVector3(0, 6, -10))
    //enemy?.localRotate(by: SCNQuaternion(0.2, 0, 0, 0))
  }
  
  func setupFriend() {
    var name = battle.getFriend().getModel().name!
    name = name.prefix(1).uppercased() + name.dropFirst().lowercased()
    let scene = SCNScene(named: "art.scnassets/Pokemon_Models/\(name)/\(name).dae")
    friend = scene!.rootNode
    let scale = 0.035
    friend.scale = SCNVector3(scale, scale, scale)
    friend.position = SCNVector3(0, -2.75, -10)
    //friend.localRotate(by: SCNQuaternion(0, 1, 0, (2 * 0.7071)))
    friend.look(at: SCNVector3(0, -4, 0))
    cameraNode.addChildNode(friend)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch = touches.first!
    let location = touch.location(in: sceneView)
    let hitResult = sceneView.hitTest(location, options: nil)
    let fireball = SCNParticleSystem(named: "Fireball.scnp", inDirectory: nil)
    let emitterNode = SCNNode()
    
    emitterNode.position = SCNVector3(0, -5, 0)
    emitterNode.addParticleSystem(fireball!)
    scene.rootNode.addChildNode(emitterNode)
    
    if hitResult.first != nil {
      target.itemNode?.runAction(SCNAction.sequence([SCNAction.wait(duration: 0.5), SCNAction.removeFromParentNode(), SCNAction.hide()]))
      let sequence = SCNAction.sequence([SCNAction.move(to: target.itemNode!.position, duration: 0.5), SCNAction.wait(duration: 3.5),
        SCNAction.run({_ in
          self.delegate?.viewController(controller: self, tappedTarget: self.target)
        })])
      emitterNode.runAction(sequence)
    } else {
      emitterNode.runAction(SCNAction.move(to: SCNVector3(0, 0, -30), duration: 0.5))
    }
  }
  
  func repositionTarget() {
    let heading = getHeadingForDirectionFromCoordinate(from: userLocation, to: target.location)
    let delta = heading - self.heading
    
    if delta < -15.0 {
      leftIndicator.isHidden = false
      rightIndicator.isHidden = true
    } else if delta > 15 {
      leftIndicator.isHidden = true
      rightIndicator.isHidden = false
    } else {
      leftIndicator.isHidden = true
      rightIndicator.isHidden = true
    }
    
    let distance = userLocation.distance(from: target.location)
    
    if let node = target.itemNode {
      if node.parent == nil {
        node.position = SCNVector3(Float(delta), 0, Float(-distance))
        scene.rootNode.addChildNode(node)
      } else {
        node.removeAllActions()
        node.runAction(SCNAction.move(to: SCNVector3(x: Float(delta), y: 0, z: Float(-distance)), duration: 0.2))
      }
    }
  }
  
  func updatePositionAndOrientationOf(_ node: SCNNode, withPosition position: SCNVector3, relativeTo referenceNode: SCNNode) {
      let referenceNodeTransform = matrix_float4x4(referenceNode.transform)

      // Setup a translation matrix with the desired position
      var translationMatrix = matrix_identity_float4x4
      translationMatrix.columns.3.x = position.x
      translationMatrix.columns.3.y = position.y
      translationMatrix.columns.3.z = position.z

      // Combine the configured translation matrix with the referenceNode's transform to get the desired position AND orientation
      let updatedTransform = matrix_multiply(referenceNodeTransform, translationMatrix)
      node.transform = SCNMatrix4(updatedTransform)
  }
  
}

extension ViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    self.heading = fmod(newHeading.trueHeading, 360.0)
    repositionTarget()
  }
}

