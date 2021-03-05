//
//  PC.swift
//  Opal
//
//  Created by William Hickman on 6/29/20.
//  Copyright © 2020 William Hickman. All rights reserved.
//

import Foundation
import PokemonAPI

class PC {
  
  private var pc: [[Pokemon?]]
  private var ndx = 0
  
  private let x = 6
  private let y = 5
  
  init() {
    pc = [[Pokemon?]]()
    pc.append([Pokemon?]())
  }
  
  func addPokemon(pokemon: Pokemon?) {
    if pc[ndx].count == x * y {
      ndx += 1
      pc.append([Pokemon?]())
    }
    
    pc[ndx].append(pokemon)
  }
  
  func getBox(index: Int) -> [Pokemon?] {
    if index > ndx {
      return [Pokemon?]()
    }
    
    return pc[index]
  }
  
  func numBoxes() -> Int {
    return ndx + 1
  }
  
}
