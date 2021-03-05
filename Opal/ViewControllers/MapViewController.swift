/*
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController {

  @IBOutlet weak var mapView: MKMapView!
  
  var targets = [ARItem]()
  var userLocation: CLLocation?
  var selectedAnnotation: MKAnnotation?
  
  var didGenerate: Bool = false
  
  let locationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if CLLocationManager.authorizationStatus() == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
    }
    locationManager.startUpdatingLocation()
    
    mapView.delegate = self
    mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
    
  }
  
  func setupLocations() {
    
    let firstTarget = ARItem(itemDescription: "Machamp", location: generateNearbyLocation(), itemNode: nil)
    let secondTarget = ARItem(itemDescription: "Arcanine", location: generateNearbyLocation(), itemNode: nil)
    let thirdTarget = ARItem(itemDescription: "Pidgey", location: generateNearbyLocation(), itemNode: nil)
    
    targets.append(firstTarget)
    targets.append(secondTarget)
    targets.append(thirdTarget)
    
    for item in targets {
      let annotation = MapAnnotation(location: item.location.coordinate, item: item)
      self.mapView.addAnnotation(annotation)
    }
  }
  
  func generateNearbyLocation() -> CLLocation {
    let roundLat = round((userLocation!.coordinate.latitude) * 1000) / 1000
    let roundLng = round((userLocation!.coordinate.longitude) * 1000) / 1000
      
    let newLat = roundLat + Double(arc4random_uniform(5)) * 0.0001
    let newLng = roundLng + Double(arc4random_uniform(5)) * 0.0001
    return CLLocation(latitude: newLat, longitude: newLng)
  }
  
}

extension MapViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    self.userLocation = userLocation.location
    
    if !didGenerate && self.userLocation != nil {
      didGenerate = true
      setupLocations()
    }
  }
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    let coordinate = view.annotation!.coordinate
    
    if let userCoordinate = userLocation {
      
      if userCoordinate.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) < 5000000 {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let viewController = storyboard.instantiateViewController(withIdentifier: "ARViewController") as? ViewController {
          
          viewController.delegate = self
          
          if let mapAnnotation = view.annotation as? MapAnnotation {
            viewController.target = mapAnnotation.item
            viewController.userLocation = mapView.userLocation.location!
            viewController.battle = Battle(enemy: Pokemon(model: PokemonManager.getPokemon(name: viewController.target.itemDescription), level: CShort(Int.random(in: 10...40))))
            selectedAnnotation = view.annotation
            self.show(viewController, sender: nil)
            //self.present(viewController, animated: true, completion: nil)
          }
          
        }
        
      }
      
    }
  }
  
}

extension MapViewController: ARControllerDelegate {
  func viewController(controller: ViewController, tappedTarget: ARItem) {
    self.dismiss(animated: true, completion: nil)
    let index = self.targets.firstIndex(where: {$0.itemDescription == tappedTarget.itemDescription})
    self.targets.remove(at: index!)
    
    if selectedAnnotation != nil {
      mapView.removeAnnotation(selectedAnnotation!)
    }
  }
}

protocol ARControllerDelegate {
  func viewController(controller: ViewController, tappedTarget: ARItem)
}
