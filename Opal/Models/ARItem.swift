//
//  ARItem.swift
//  AR_Hunt
//
//  Created by William Hickman on 6/24/20.
//  Copyright © 2020 Razeware LLC. All rights reserved.
//

import Foundation
import CoreLocation
import SceneKit

struct ARItem {
  var itemDescription: String {
    didSet {
      pokemon = Pokemon(model: PokemonManager.getPokemon(name: itemDescription))
    }
  }
  let location: CLLocation
  var itemNode: SCNNode?
  var pokemon: Pokemon?
}
