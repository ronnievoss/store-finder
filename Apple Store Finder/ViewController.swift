//
//  ViewController.swift
//  Apple Store Finder
//
//  Created by Ronnie Voss on 2/13/16.
//  Copyright © 2016 Ronnie Voss. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    var locationManager : CLLocationManager?
    
    // MARK: Outlets
    
    @IBOutlet weak var textLabel: UILabel?
    @IBOutlet weak var mapContainerView: UIView?
    @IBOutlet weak var searchButton: UIButton?
    
    // MARK: Actions
    
    @IBAction func didTapSearchButton(_ sender: UIButton) {
        sender.isEnabled = false
        self.mapViewController?.activityIndicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        searchForNearestLocation()
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        self.mapViewController?.mapView!.showsUserLocation = true
        self.mapViewController?.activityIndicator.hidesWhenStopped = true
        self.mapViewController?.activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        setupContainerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideTextLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateEntrance()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? MapViewController {
            mapViewController = controller
        }
    }
    
    // MARK: Private
    
    private var mapViewController: MapViewController?
    
    private func animateEntrance() {
        
        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut, animations: { () -> Void in
            
            self.textLabel?.alpha = 1.0
            self.searchButton?.alpha = 1.0
            
            self.textLabel?.transform = CGAffineTransform.identity
            self.searchButton?.transform = CGAffineTransform.identity
            
            }, completion: nil)
    }
    
    private func hideTextLabel() {
        let yTranslation: CGFloat = 150.0
        
        textLabel?.alpha = 0.0
        searchButton?.alpha = 0.0
        
        textLabel?.transform = CGAffineTransform(translationX: 0, y: yTranslation)
        searchButton?.transform = CGAffineTransform(translationX: 0, y: -yTranslation)
        
    }
    
    private func searchForNearestLocation() {
        let operation = FindNearestAppleStoreOperation()
        operation.qualityOfService = .userInitiated

        operation.successHandler = { location in
            DispatchQueue.main.async {
                self.mapViewController?.location = location
            }
            self.mapViewController?.distance = operation.roundedDistance!
            self.mapViewController?.activityIndicator.stopAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        operation.errorHandler = { error in
            DispatchQueue.main.async {
                let err = operation.errMessage != nil ? operation.errMessage : error.localizedDescription
                let controller = UIAlertController(title: err, message: nil, preferredStyle: .alert)
                let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
                    if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                    }
                }
                if operation.errMessage != nil {
                    controller.addAction(settingsAction)
                }
                controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { Void in
                    self.mapViewController?.activityIndicator.stopAnimating() }))
                
                self.show(controller, sender: nil)
            }
        }
        
        operation.completionBlock = {
            self.searchButton?.isEnabled = true
        }
        
        OperationQueue.main.addOperation(operation)
    }
    
    private func setupContainerView() {
        mapContainerView?.layer.cornerRadius = 15
        mapContainerView?.layer.masksToBounds = true
    }
}

