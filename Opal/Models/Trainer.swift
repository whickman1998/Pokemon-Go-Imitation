//
//  Trainer.swift
//  Opal
//
//  Created by William Hickman on 6/29/20.
//  Copyright © 2020 William Hickman. All rights reserved.
//

import Foundation
import PokemonAPI

class Trainer {
  
  var name: String
  var party: [Pokemon]
  var pc: PC
  
  init(name: String) {
    self.name = name
    self.party = [Pokemon]()
    self.pc = PC()
  }
  
  func addToParty(pokemon: Pokemon) {
    if party.count < 6 {
      party.append(pokemon)
    } else {
      pc.addPokemon(pokemon: pokemon)
    }
  }
  
  public func nextPokemon() -> Pokemon? {
    for pokemon in party {
      if pokemon.getCurrentHealth() > 0 {
        return pokemon
      }
    }
    return nil
  }
  
}
