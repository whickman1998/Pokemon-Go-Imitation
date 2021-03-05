//
//  Pokemon.swift
//  Opal
//
//  Created by William Hickman on 7/23/20.
//  Copyright © 2020 William Hickman. All rights reserved.
//

import Foundation
import PokemonAPI

//class for pokemon actually in existence in the game (ie. party pokemon, etc.)
class Pokemon {
  
  private var model: PKMPokemon
  private var species: PKMPokemonSpecies
  private var stats: [PKMPokemonStat]
  private var level: CShort
  private var currMoves: [PKMMove]
  private var moveIndex = 0
  private var types = [PKMType]()
  private var currExperience: Int = 0
  private var neededExperience: Int = -1
  private var health: Int = -1
  private var maxHealth: Int = -1
  
  //next species for evolution, same one of current if done evolving
  private var nextEvo: PKMPokemonSpecies? = nil
  
  init(model: PKMPokemon) {
    self.model = model
    self.species = PokemonManager.getSpeciesFromName(name: model.species!.name!)
    
    //stats go as follows: hp, attack, defense, special-attack, special-defense, speed
    self.stats = model.stats!
    
    self.level = 1
    self.currMoves = [PKMMove]()
    initMoves()
    for type in model.types! {
      types.append(PokemonManager.getTypeFromName(name: type.type!.name!))
    }
    getNeededExperience()
    findMaxHealth()
    health = maxHealth
  }
  
  init(model: PKMPokemon, level: CShort) {
    self.model = model
    self.species = PokemonManager.getSpeciesFromName(name: model.species!.name!)
    self.stats = model.stats!
    self.level = level
    self.currMoves = [PKMMove]()
    initMoves()
    for type in model.types! {
      types.append(PokemonManager.getTypeFromName(name: type.type!.name!))
    }
    getNeededExperience()
    findMaxHealth()
    health = maxHealth
  }
  
  //Unsure about array index
  private func getNeededExperience() {
    let expLevel = PokemonManager.getGrowthRateFromName(name: species.growthRate!.name!).levels![Int(level)]
    if expLevel.level! != level + 1 {
      NSLog("levels are uncalibrated, rip (desired level and exp level)")
      NSLog(String(level + 1))
      NSLog(String(expLevel.level!))
      exit(1)
    }
    self.neededExperience = expLevel.experience!
  }
  
  private func findMaxHealth() {
    /*actual formula goes as follows:
      ({[IV + 2 * Base Stat + ([EVs]/4) + 100] * Level} / 100) + 10
      simplified implementation goes as:
      ({[2 * Base Stat + 100] * Level} / 100) + 10
    */
    maxHealth = 2 * stats[0].baseStat!
    maxHealth += 100
    maxHealth *= Int(level)
    maxHealth /= 100
    maxHealth += 10
  }
  
  //altering health by healing (positive amount) or damage (negative amount)
  public func changeHealth(amount: Int) {
    health += amount
    if health < 0 {
      health = 0
    } else if health > maxHealth {
      health = maxHealth
    }
  }
  
  public func getTypes() -> [PKMType] {
    return self.types
  }
  
  public func getModel() -> PKMPokemon {
    return self.model
  }
  
  public func getMaxHealth() -> Int {
    return self.maxHealth
  }
  
  public func getCurrentHealth() -> Int {
    return self.health
  }
  
  public func getStats() -> [PKMPokemonStat] {
    return self.stats
  }
  
  public func getCurrMoves() -> [PKMMove] {
    return currMoves
  }
  
  public func getLevel() -> CShort {
    return level
  }
  
  public func addExp(exp: Int) -> Bool {
    currExperience += exp
    if currExperience >= neededExperience {
      levelUp()
      return true
    }
    return false
  }
  
  public func levelUp() {
    if level == 100 {
      return
    }
    level += 1
    if checkEvolution() {
      evolve()
      return
    }
    getNeededExperience()
    
    let offset = maxHealth - health
    findMaxHealth()
    health = maxHealth - offset
    
    if let potentialMoves = model.moves {
      if potentialMoves[moveIndex].versionGroupDetails![0].levelLearnedAt! <= level {
        moveIndex += 1
      }
    }
    if currExperience >= neededExperience {
      levelUp()
    }
  }
  
  public func isType(target: PKMType) -> Bool {
    var result = false
    for type in self.types {
      if type.name! == target.name! {
        result = true
      }
    }
    return result
  }
  
  //determine whether it is time to evolve or not
  private func checkEvolution() -> Bool {
    var result: Bool = false
    
    //if next evolution not determined yet, then call and traverse evolution chain in order to set up the next one
    if nextEvo == nil {
      
      let chnlnk = PokemonManager.findChainLinkFromSpecies(species: species)
      
      if chnlnk.evolvesTo == nil || chnlnk.evolvesTo!.count <= 0 {
        //nothing to evolve to, default next evolution is itself
        nextEvo = PokemonManager.getSpeciesFromName(name: chnlnk.species!.name!)
      } else {
        nextEvo = PokemonManager.getSpeciesFromName(name: chnlnk.evolvesTo![0].species!.name!)
      }
    }
    
    //quick check to see if evolving is still possible
    if nextEvo!.id! == species.id! {
      return false
    }
    
    //now we determine if the pokemon is at the proper level to evolve
    let minLevel = PokemonManager.findChainLinkFromSpecies(species: nextEvo!).evolutionDetails![0].minLevel!
    
    if self.level >= minLevel {
      result = true
    }
    
    return result
  }
  
  //performs the evolving process
  private func evolve() {
    self.model = PokemonManager.getPokemon(name: nextEvo!.name!)
    self.species = nextEvo!
    self.nextEvo = nil
  }
  
  private func initMoves() {
    if let potentialMoves = model.moves {
      while moveIndex < potentialMoves.count {
        let moveInfo = potentialMoves[moveIndex]
        if moveInfo.versionGroupDetails![0].levelLearnedAt! <= level {
          currMoves.append(PokemonManager.getMoveFromName(name: moveInfo.move!.name!))
        } else {
          break
        }
        moveIndex += 1
      }
      if currMoves.count > 4 {
        currMoves.removeSubrange(0...(currMoves.count - 4))
      }
    }
  }
  
}
