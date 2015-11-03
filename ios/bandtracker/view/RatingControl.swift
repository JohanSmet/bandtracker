//
//  RatingControl.swift
//  bandtracker
//
//  Created by Johan Smet on 11/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

protocol RatingControlDelegate {
    func ratingDidChange(ratingControl : RatingControl, newRating : Float, oldRating : Float);
}

@IBDesignable
class RatingControl : UIView {
    
    @IBInspectable var numberOfStars : Int = 5
    @IBInspectable var gapBetweenStars : CGFloat = 3
    @IBInspectable var strokeColor : UIColor = UIColor.blackColor()
    @IBInspectable var fillColor : UIColor = UIColor.yellowColor()
    
    @IBInspectable var enabled : Bool = true
    @IBInspectable var rating : Float = 5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var starSize : CGFloat = 0
    var delegate : RatingControlDelegate?
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // custom draw routine
    //

    override func drawRect(rect: CGRect) {
        
        // determine the size of the stars
        let availableWidth = rect.width - (gapBetweenStars * CGFloat(numberOfStars - 1)) - 4.5
        starSize = min(rect.height - 1, availableWidth / CGFloat(numberOfStars))
        let outerRadius = starSize / 2
        let innerRadius = starSize / 5
        
        // determinate the position of the first star
        var x : CGFloat = 4.5 + (starSize / 2)
        let y : CGFloat = rect.height / 2
        
        // set context properties
        fillColor.setFill()
        strokeColor.setStroke()
        
        // draw the stars
        for var starIdx: Int = 0; starIdx < numberOfStars; ++starIdx {
            let path = createStarPath(CGPointMake(x, y), numPoints: 5, innerRadius: innerRadius, outerRadius: outerRadius)
            
            if Float(starIdx + 1) <= rating {
                path.fill()
            }
            
            path.stroke()
            
            x += starSize + gapBetweenStars
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // handle input
    //
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !enabled {
            return
        }
        
        for touch in touches {
            handleTouchAtPoint(touch.locationInView(self))
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !enabled {
            return
        }
        
        for touch in touches {
            handleTouchAtPoint(touch.locationInView(self))
        }
    }
    
    private func handleTouchAtPoint(location : CGPoint) {
        
        var starPos : CGFloat = 4.5
        let oldRating = rating
        rating = 0
        
        while rating <= 5 && location.x >= starPos {
            ++rating
            starPos += starSize + gapBetweenStars
        }
        
        if oldRating != rating {
            self.setNeedsDisplay()
            
            if let delegate = delegate {
                delegate.ratingDidChange(self, newRating: rating, oldRating : oldRating)
            }
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private func createStarPath(center : CGPoint, numPoints : Int, innerRadius : CGFloat, outerRadius : CGFloat) -> UIBezierPath {
        
        let path  = UIBezierPath()
        var angle      = CGFloat((3 * M_PI) / 2)
        let angleDelta = CGFloat(M_PI) / CGFloat(numPoints)
       
        for idx in 0 ..< numPoints * 2 {
            
            let radius  = (idx & 1) == 0 ? outerRadius : innerRadius
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            angle += angleDelta
            
            if idx == 0 {
                path.moveToPoint(CGPointMake(x, y))
            } else {
                path.addLineToPoint(CGPointMake(x, y))
            }
        }
        
        path.closePath()
        
        return path
    }
    
    
    
}