//
//  BattleViewController.swift
//  Opal
//
//  Created by William Hickman on 7/23/20.
//  Copyright © 2020 William Hickman. All rights reserved.
//

import UIKit
import PokemonAPI

class BattleViewController: UIViewController {

  //existence of trainer indicates a trainer battle, absense indicates it is a wild pokemon
  public var trainer: Trainer?
  
  //opponent's pokemon index
  private var ondx = 1
  
  //assuming will be passed down from previous view controller if no trainer
  private var currentOpponent: Pokemon?
  
  //user's pokemon index
  private var undx = 1
  
  //user's pokemon in battle
  private var currentFriend: Pokemon = User.getTrainer().party[0]
  
  override func viewDidLoad() {
    super.viewDidLoad()

    if let opp = trainer {
      currentOpponent = opp.party[0]
    }
    
    //temporary oppenent for testing
    currentOpponent = Pokemon(model: PokemonManager.getPokemon(name: "Pidgey"), level: 2)
    
    
  }
    
  //cycles to next opponent pokemon if available
  private func oppDefeated() {
    currentFriend.addExp(exp: currentOpponent!.getModel().baseExperience!)
    if trainer != nil && trainer!.party.count > ondx {
      currentOpponent = trainer!.party[ondx]
      ondx += 1
    } else {
      victory()
    }
  }
  
  private func friendDefeated() {
    if User.getTrainer().party.count > undx {
      currentFriend = User.getTrainer().party[undx]
      undx += 1
    } else {
      defeat()
    }
  }
  
  private func victory() {
    
  }
  
  private func defeat() {
    
  }

  /*
  // MARK: - Navigation
   
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      // Get the new view controller using segue.destination.
      // Pass the selected object to the new view controller.
  }
  */

}
