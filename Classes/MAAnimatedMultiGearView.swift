//
//  MAAnimatedMultiGearView.swift
//  MAGearRefreshControl-Demo
//
//  Created by Michaël Azevedo on 20/02/2017.
//  Copyright © 2017 micazeve. All rights reserved.
//

import UIKit

//MARK: - MAAnimatedMultiGearView Class

/// This class is used to draw and animate multiple gears

public class MAAnimatedMultiGearView: MAMultiGearView {
    
    //MARK: Instance properties
    
    
    /// Enum representing the animation style
    internal enum MAGearRefreshAnimationStyle: UInt8 {
        case singleGear    // Only the main gear is rotating when the data is refreshing
        case keepGears     // All the gear are still visible during the refresh and disappear only when its finished
    }
    
    /// Animation style of the refresh control
    internal var style = MAGearRefreshAnimationStyle.keepGears
    
    /// Array of rotational angle for the refresh
    fileprivate var arrayOfRotationAngle:[CGFloat] = [180]
    
    /// Workaround for the issue with the CGAffineTransformRotate (when angle > M_PI its rotate clockwise beacause it's shorter)
    fileprivate var divisionFactor: CGFloat = 1
    
    /// Variable used to rotate or no the gear
    var stopRotation = true
    
    /// Boolean used to know if the view is already animated
    var isRotating = false
    
    //MARK: Various methods
    
    /// Override of the `addLinkedGear` method in order to update the array of rotational angle when a gear is added
    override public func addLinkedGear(_ gearLinked: Int, nbTeeth:UInt, color:UIColor, angleInDegree:Double, gearStyle:MASingleGearView.MAGearStyle = .Normal, nbBranches:UInt = 5) -> Bool {
        
        if !super.addLinkedGear(gearLinked, nbTeeth: nbTeeth, color: color, angleInDegree: angleInDegree, gearStyle: gearStyle, nbBranches: nbBranches) {
            return false
        }
        
        let ratio = CGFloat(arrayViews[gearLinked].gear.nbTeeth) / CGFloat(arrayViews[arrayViews.count - 1].gear.nbTeeth)
        let newAngle = -1 * arrayOfRotationAngle[gearLinked] * ratio
        /*
         NSLog("addLinkedGear \(gearLinked) , \(nbTeeth) , \(angleInDegree)")
         
         NSLog("     angleOtherGear : \(arrayOfRotationAngle[gearLinked])")
         NSLog("     ratio : \(ratio)")
         NSLog("     newAngle : \(newAngle)")
         */
        
        arrayOfRotationAngle.append(newAngle)
        
        let angleScaled = 1+floor(abs(newAngle)/180)
        
        if angleScaled > divisionFactor {
            divisionFactor = angleScaled
        }
        
        return true
    }
    
    
    /// Method called to rotate the main gear by 360 degree
    internal func rotate() {
        
        if !stopRotation && !isRotating {
            isRotating = true
            
            let duration = TimeInterval(1/divisionFactor)
            /*
             NSLog("rotation 0 \(self.arrayOfRotationAngle[0] / 180 * CGFloat(M_PI) / self.divisionFactor)" )
             NSLog(" -> duration : \(duration)")
             */
            UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: { () -> Void in
                
                switch self.style {
                case .singleGear:
                    self.arrayViews[0].transform = self.arrayViews[0].transform.rotated(by: self.arrayOfRotationAngle[0] / 180 * CGFloat(M_PI))
                case .keepGears:
                    for i in 0..<self.arrayViews.count {
                        let view = self.arrayViews[i]
                        view.transform = view.transform.rotated(by: self.arrayOfRotationAngle[i] / 180 * CGFloat(M_PI) / self.divisionFactor)
                    }
                }
                
                
            }, completion: { (finished) -> Void in
                // NSLog("     -> completion \(finished)") 
                self.isRotating = false
                self.rotate()
            })
        }
    }
    
    /// Public method to start rotating
    public func startRotating() {
        stopRotation = false
        rotate()
    }
    
    
    /// Public method to start rotating
    public func stopRotating() {
        stopRotation = true
    }
}
