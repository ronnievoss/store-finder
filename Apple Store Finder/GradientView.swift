//
//  GradientView.swift
//  Apple Store Finder
//
//  Created by Ronnie Voss on 2/19/16.
//  Copyright © 2016 Ronnie Voss. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class GradientView: UIView {

    // MARK: Inspectable properties ******************************
    
    @IBInspectable var startColor: UIColor = UIColor.white {
        didSet{
            setupView()
        }
    }
    
    @IBInspectable var endColor: UIColor = UIColor.black {
        didSet{
            setupView()
        }
    }
    
    @IBInspectable var isHorizontal: Bool = false {
        didSet{
            setupView()
        }
    }
    
    @IBInspectable var roundness: CGFloat = 0.0 {
        didSet{
            setupView()
        }
    }
    
    // MARK: Internal functions *********************************
    
    // Setup the view appearance
    private func setupView(){
        
        let colors:Array = [startColor.cgColor, endColor.cgColor]
        gradientLayer.colors = colors
        gradientLayer.cornerRadius = roundness
        
        if (isHorizontal){
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        }else{
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        }
        
        gradientLayer.locations = [0.3, 1.0]
        
        self.setNeedsDisplay()
        
    }
    
    // Helper to return the main layer as CAGradientLayer
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    // MARK: Overrides ******************************************
    
    override class var layerClass: AnyClass{
        return CAGradientLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

}
