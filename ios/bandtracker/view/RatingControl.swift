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
    func ratingDidChange(_ ratingControl : RatingControl, newRating : Float, oldRating : Float);
}

@IBDesignable
class RatingControl : UIControl {
    
    @IBInspectable var numberOfStars : Int = 5
    @IBInspectable var gapBetweenStars : CGFloat = 3
    @IBInspectable var strokeColor : UIColor = UIColor.black
    @IBInspectable var fillColor : UIColor = UIColor.yellow
    
    @IBInspectable var rating : Float = 5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    fileprivate var starSize : CGFloat = 0
    var delegate : RatingControlDelegate?
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // custom draw routine
    //

    override func draw(_ rect: CGRect) {
        
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
        for starIdx: Int in 0 ..< numberOfStars {
            let path = createStarPath(CGPoint(x: x, y: y), numPoints: 5, innerRadius: innerRadius, outerRadius: outerRadius)
            
            if Float(starIdx + 1) <= rating {
                path.fill()
            }
            
            path.stroke()
            
            x += starSize + gapBetweenStars
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // handle input
    //
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isEnabled {
            return
        }
        
        for touch in touches {
            handleTouchAtPoint(touch.location(in: self))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isEnabled {
            return
        }
        
        for touch in touches {
            handleTouchAtPoint(touch.location(in: self))
        }
    }
    
    fileprivate func handleTouchAtPoint(_ location : CGPoint) {
        
        var starPos : CGFloat = 4.5
        let oldRating = rating
        rating = 0
        
        while rating <= 5 && location.x >= starPos {
            rating += 1
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
    
    fileprivate func createStarPath(_ center : CGPoint, numPoints : Int, innerRadius : CGFloat, outerRadius : CGFloat) -> UIBezierPath {
        
        let path  = UIBezierPath()
        var angle      = CGFloat((3 * Float.pi) / 2)
        let angleDelta = CGFloat(Float.pi) / CGFloat(numPoints)
       
        for idx in 0 ..< numPoints * 2 {
            
            let radius  = (idx & 1) == 0 ? outerRadius : innerRadius
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            angle += angleDelta
            
            if idx == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.close()
        
        return path
    }
    
    
    
}
