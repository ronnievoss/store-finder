//
//  FindNearestAppleStoreOperation.swift
//  Apple Store Finder
//
//  Created by Ronnie Voss on 2/22/16.
//  Copyright © 2016 Ronnie Voss. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class FindNearestAppleStoreOperation: Operation {

    typealias LocationFoundHandler = ((MKMapItem) -> Void)
    typealias ErrorHandler = ((NSError) -> Void)
    
    let manager = CLLocationManager()
    var successHandler: LocationFoundHandler?
    var errorHandler: ErrorHandler?
    var errMessage: String?
    var roundedDistance: Double?
    
    var _finished: Bool = false
    
    override var isFinished:Bool {
        get { return _finished }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

    // MARK: NSOperation
    
    override func start() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.requestLocation()
    }
    
    // MARK: Private
    
    func finish() {
        isFinished = true
        completionBlock?()
    }
}

extension FindNearestAppleStoreOperation: CLLocationManagerDelegate {
    
    @objc(locationManager:didUpdateLocations:) func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer {
            finish()
        }
        
        guard let location = locations.first else { return }
        
        let request = MKLocalSearchRequest()
        request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.1, 0.1))
        request.naturalLanguageQuery = "Apple Store"
        
        MKLocalSearch(request: request).start { (response, error) -> Void in
            guard error == nil else { self.errorHandler?(error! as NSError); return }
            guard let result = response?.mapItems.first else { self.errMessage = "No results"; return }
            
            let distance: CLLocationDistance = location.distance(from: result.placemark.location!) * 0.000621371
            self.roundedDistance = Double(round(distance * 10) / 10)

            self.successHandler?(result)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        defer {
            finish()
        }
        let clErr = CLError(_nsError: error as NSError).code
            switch clErr {
            case .locationUnknown:
                errMessage = "Location cannot be determined"
            case .denied:
                errMessage = "Permission Denied"
            default:
                errMessage = ""
            
        }
        errorHandler?(error as NSError)
    }

}
