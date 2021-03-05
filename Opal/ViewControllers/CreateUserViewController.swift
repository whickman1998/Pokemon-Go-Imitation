//
//  CreateUserViewController.swift
//  Opal
//
//  Created by William Hickman on 7/22/20.
//  Copyright © 2020 William Hickman. All rights reserved.
//

import UIKit
import PokemonAPI

class CreateUserViewController: UIViewController {

    var starter: String?
    var name: String?
  
    @IBOutlet var NameField: UITextField!
  
  @IBOutlet var BulbaButton: UIButton!
  @IBOutlet var CharButton: UIButton!
  @IBOutlet var SquirButton: UIButton!
  
  override func viewDidLoad() {
      super.viewDidLoad()
      NameField.delegate = self
      BulbaButton.imageView?.image = UIImage(named: "Bulbasaur.png")
      CharButton.imageView?.image = UIImage(named: "Charmander.png")
      SquirButton.imageView?.image = UIImage(named: "Squirtle.png")
    }
    
    @IBAction func BulbaButtonPressed(_ sender: Any) {
      starter = "Bulbasaur"
      BulbaButton.isSelected = true
      CharButton.isSelected = false
      SquirButton.isSelected = false
    }
  
    @IBAction func CharButtonPressed(_ sender: Any) {
      starter = "Charmander"
      BulbaButton.isSelected = false
      CharButton.isSelected = true
      SquirButton.isSelected = false
    }
  
    @IBAction func SquirButtonPressed(_ sender: Any) {
      starter = "Squirtle"
      BulbaButton.isSelected = false
      CharButton.isSelected = false
      SquirButton.isSelected = true
    }
  
    @IBAction func toNextVCPressed(_ sender: Any) {
      if starter != nil && name != nil {
        User.setup(name: name!, starter: starter!)
        NSLog(starter!)
        NSLog(name!)
        performSegue(withIdentifier: "toBattle", sender: nil)
      }
    }

}

extension CreateUserViewController: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
      return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    name = NameField.text
    textField.resignFirstResponder()
    return true
  }
}
