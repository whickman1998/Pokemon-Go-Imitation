//
//  PokemonManager.swift
//  Opal
//
//  Created by William Hickman on 6/29/20.
//  Copyright © 2020 William Hickman. All rights reserved.
//

import Foundation
import PokemonAPI

class PokemonManager {
  
  //dictionary of types weak to a key type
  private static var superEffective: [String: [String]] = [:]
  
  //dictionary of types strong to a key type
  private static var notVeryEffective: [String: [String]] = [:]
  
  static func getPokemon(name: String) -> PKMPokemon {
    var p: PKMPokemon?
    let semaphore = DispatchSemaphore(value: 0)
    PokemonAPI.pokemonService.fetchPokemon(name.lowercased(), completion: { result in
      switch result {
      case .success(let pokemon):
        p = pokemon
      case .failure(let error):
        print(error.localizedDescription)
        exit(1)
      }
      semaphore.signal()
    })
    semaphore.wait()
    return p!
  }
  
  static func getMoveFromName(name: String) -> PKMMove {
    var m: PKMMove?
    let semaphore = DispatchSemaphore(value: 0)
    PokemonAPI.moveService.fetchMove(name, completion: { result in
      switch result {
      case .success(let move):
        m = move
      case .failure(let error):
        print(error.localizedDescription)
        exit(1)
      }
      semaphore.signal()
    })
    semaphore.wait()
    return m!
  }
  
  static func getSpeciesFromName(name: String) -> PKMPokemonSpecies {
    var s: PKMPokemonSpecies?
    let semaphore = DispatchSemaphore(value: 0)
    PokemonAPI.pokemonService.fetchPokemonSpecies(name, completion: { result in
      switch result {
      case .success(let species):
        s = species
      case .failure(let error):
        print(error.localizedDescription)
        exit(1)
      }
      semaphore.signal()
    })
    semaphore.wait()
    return s!
  }
  
  static func getTypeFromName(name: String) -> PKMType {
    var t: PKMType?
    let semaphore = DispatchSemaphore(value: 0)
    PokemonAPI.pokemonService.fetchType(name, completion: { result in
      switch result {
      case .success(let type):
        t = type
      case .failure(let error):
        print(error.localizedDescription)
        exit(1)
      }
      semaphore.signal()
    })
    semaphore.wait()
    return t!
  }
  
  static func getGrowthRateFromName(name: String) -> PKMGrowthRate {
    var gr: PKMGrowthRate?
    let semaphore = DispatchSemaphore(value: 0)
    PokemonAPI.pokemonService.fetchGrowthRate(name, completion: { result in
      switch result {
      case .success(let growthrate):
        gr = growthrate
      case .failure(let error):
        print(error.localizedDescription)
        exit(1)
      }
      semaphore.signal()
    })
    semaphore.wait()
    return gr!
  }
  
  static func getEvolutionChainFromResource(ecResource: PKMAPIResource<PKMEvolutionChain>) -> PKMEvolutionChain {
    var ec: PKMEvolutionChain?
    let semaphore = DispatchSemaphore(value: 0)
    PokemonAPI.resourceService.fetch(ecResource, completion: { result in
      switch result {
      case .success(let evolutionChain):
        ec = evolutionChain
      case .failure(let error):
        print(error.localizedDescription)
        exit(1)
      }
      semaphore.signal()
    })
    semaphore.wait()
    return ec!
  }
  
  static func findChainLinkFromSpecies(species: PKMPokemonSpecies) -> PKMClainLink {
    var chainlink = getEvolutionChainFromResource(ecResource: species.evolutionChain!).chain!
    while chainlink.species!.name != species.name && chainlink.evolvesTo != nil && chainlink.evolvesTo!.count > 0 {
      chainlink = chainlink.evolvesTo![0]
    }
    return chainlink
  }
  
  static func moveToTypeModifier(move: PKMMove, target: Pokemon) -> Double {
    let moveType = PokemonManager.getTypeFromName(name: move.type!.name!)
    var modifier = 1.0
    
    if superEffective[moveType.name!] == nil {
      var temp = [String]()
      for nr in moveType.damageRelations!.doubleDamageTo! {
        temp.append(nr.name!)
      }
      superEffective[moveType.name!] = temp
    }
    if notVeryEffective[moveType.name!] == nil {
      var temp = [String]()
      for nr in moveType.damageRelations!.doubleDamageFrom! {
        temp.append(nr.name!)
      }
      notVeryEffective[moveType.name!] = temp
    }
    
    for targetType in target.getTypes() {
      if superEffective[moveType.name!]!.contains(targetType.name!)  {
        modifier *= 2.0
      } else if notVeryEffective[moveType.name!]!.contains(targetType.name!) {
        modifier *= 0.5
      }
    }
    
    return modifier
  }
  
}
