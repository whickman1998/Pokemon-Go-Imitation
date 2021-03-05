//
//  Battle.swift
//  Opal
//
//  Created by William Hickman on 7/30/20.
//  Copyright © 2020 William Hickman. All rights reserved.
//

import Foundation
import PokemonAPI

//Helper class to do everthing battle related
class Battle {
  
  private var friend: Pokemon
  private var enemy: Pokemon
  private var opponent: Trainer?
  
  public init (enemy: Pokemon) {
    self.friend = User.getTrainer().nextPokemon()!
    self.enemy = enemy
  }
  
  public init (opponent: Trainer) {
    self.friend = User.getTrainer().nextPokemon()!
    self.opponent = opponent
    self.enemy = self.opponent!.nextPokemon()!
  }
  
  public func getFriend() -> Pokemon {
    return friend
  }
  
  public func getEnemy() -> Pokemon {
    return enemy
  }
  
  public func getOpponent() -> Trainer? {
    return opponent
  }
  
  public func setFriend(next: Pokemon) {
    self.friend = next
  }
  
  public func setEnemy(next: Pokemon) {
    self.enemy = next
  }
  
  public func friendTurn(move: PKMMove) {
    let damage = calcDamage(move: move, dealer: friend, target: enemy)
    enemy.changeHealth(amount: damage * -1)
  }
  
  public func enemyTurn() -> PKMMove {
    let move = getEnemyMove()
    let damage = calcDamage(move: move, dealer: enemy, target: friend)
    friend.changeHealth(amount: damage * -1)
    return move
  }
  
  public func getEnemyMove() -> PKMMove {
    var result: PKMMove?
    var top = 0.0
    for move in enemy.getCurrMoves() {
      let modifier = PokemonManager.moveToTypeModifier(move: move, target: friend)
      if modifier > 1.0 && modifier > top {
        top = modifier
        result = move
      }
    }
    if result != nil {
      return result!
    } else {
      return enemy.getCurrMoves()[Int.random(in: 0...enemy.getCurrMoves().count - 1)]
    }
  }
  
  public func doIMoveFirst() -> Bool {
    if friend.getStats()[5].baseStat! >= enemy.getStats()[5].baseStat! {
      return true
    } else {
      return false
    }
  }
  
  public func calcDamage(move: PKMMove, dealer: Pokemon, target: Pokemon) -> Int {
    var B: Double = Double(dealer.getStats()[1].baseStat!) //attack
    var D: Double = Double(target.getStats()[2].baseStat!) //defense
    if move.damageClass!.name! != "physical" {
      B = Double(dealer.getStats()[3].baseStat!) //special-attack
      D = Double(target.getStats()[4].baseStat!) //special-defense
    }
    var X: Double = 1.0
    if (dealer.isType(target: PokemonManager.getTypeFromName(name: move.type!.name!))) {
      X = 1.5
    }
    
    var damage: Double = 2.0 * Double(dealer.getLevel())
    
    damage *= criticalModifier()
    damage /= 5
    damage += 2
    damage *= B
    damage *= Double(move.power!)
    damage /= D
    damage /= 50
    damage += 2
    damage *= X
    damage *= PokemonManager.moveToTypeModifier(move: move, target: target)
    damage *= Double(Int.random(in: 217...255))
    damage /= 255.0
    
    return Int(damage)
  }
  
  private func criticalModifier() -> Double {
    return 1.0
  }
  
  public func timer(seconds: Int) {
    /* timeLeft = seconds
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
      timeLeft -= 1
      if timeLeft == 0 {
        timer.invalidate()
      }
    })*/
    /*let semaphore = DispatchSemaphore(value: 0)
    let timer = Timer.scheduledTimer(withTimeInterval: Double(seconds), repeats: true, block: { timer in
      timer.invalidate()
      semaphore.signal()
    })
    timer.fire()
    semaphore.wait()*/
    do {
      sleep(UInt32(seconds))
    }
  }
  
}
