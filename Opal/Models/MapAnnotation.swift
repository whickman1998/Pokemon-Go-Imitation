//
//  MapAnnotation.swift
//  AR_Hunt
//
//  Created by William Hickman on 6/24/20.
//  Copyright © 2020 Razeware LLC. All rights reserved.
//

import Foundation
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
  
  let coordinate: CLLocationCoordinate2D
  let title: String?
  let item: ARItem
  
  init(location: CLLocationCoordinate2D, item: ARItem) {
    self.coordinate = location
    self.item = item
    self.title = item.itemDescription
    
    super.init()
  }
  
}
