//
//  MapViewController.swift
//  Apple Store Finder
//
//  Created by Ronnie Voss on 2/16/16.
//  Copyright © 2016 Ronnie Voss. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // The nearest location
    
    var distance: Double?
    var location: MKMapItem? {
        didSet {
            guard let mapView = mapView else { return }
            guard let annotation = location?.placemark else { return }
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation)
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // MARK: Private
    
    @objc func didTapDirectionsButton() {
        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        location?.openInMaps(launchOptions: launchOptions)
    
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPlacemark else { return nil }
        
        let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "View") as? MKPinAnnotationView ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: "View")
    
        pinView.animatesDrop = true
        pinView.canShowCallout = true
        pinView.detailCalloutAccessoryView = buildDirectionsButton()

        return pinView
    }
    
    // MARK: Private
    
    private func buildDirectionsButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("\(self.distance!) miles                 Get Directions", for: UIControlState())
        button.addTarget(self, action: #selector(MapViewController.didTapDirectionsButton), for: .touchUpInside)
        button.sizeToFit()
        
        return button
    }
}
