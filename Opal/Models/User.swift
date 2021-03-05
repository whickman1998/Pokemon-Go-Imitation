//
//  User.swift
//  Opal
//
//  Created by William Hickman on 6/29/20.
//  Copyright © 2020 William Hickman. All rights reserved.
//

import Foundation
import PokemonAPI

class User {
  
  private static var user: User = User(name: "placeholder")
  private var startTime: Date?
  private var trainer: Trainer?
  
  public static func setup(name: String, starter: String) {
    
    let pokemon = PokemonManager.getPokemon(name: starter)
    
    User.user = User(name: name)
    User.user.startTime = Date()
    User.user.trainer = Trainer(name: name)
    User.user.trainer!.addToParty(pokemon: Pokemon(model: pokemon, level: 5))
    print("should have run")
  }
  
  private init(name: String) {
    startTime = Date()
    trainer = Trainer(name: name)
  }
  
  static func getPlayTime() -> Double {
    let endTime = Date()
    return endTime.timeIntervalSince(User.user.startTime!)
  }
  
  static func getTrainer() -> Trainer {
    return User.user.trainer!
  }
  
}
