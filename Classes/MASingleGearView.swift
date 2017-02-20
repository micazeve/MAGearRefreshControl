//
//  MASingleGearView.swift
//  MAGearRefreshControl-Demo
//
//  Created by Michaël Azevedo on 20/02/2017.
//  Copyright © 2017 micazeve. All rights reserved.
//

import UIKit


//MARK: - MASingleGearView Class

/// This class is used to draw a gear in a UIView.
public class MASingleGearView : UIView {
    
    //MARK: Instance properties
    
    /// Gear linked to this view.
    internal var gear:MAGear!
    
    /// Color of the gear.
    public var gearColor = UIColor.black
    
    /// Phase of the gear. Varies between 0 and 1.
    /// A phase of 0 represents a gear with the rightmost tooth fully horizontal, while a phase of 0.5 represents a gear with a hole in the rightmost point.
    /// A phase of 1 thus is graphically equivalent to a phase of 0
    public var phase:Double = 0
    
    //MARK: Init methods
    
    /// Custom init method
    ///
    /// - parameter gear: Gear linked to this view
    /// - parameter gearColor: Color of the gear
    public init(gear:MAGear, gearColor:UIColor) {
        
        var width = Int(gear.outsideDiameter + 1)
        if width%2 == 1 {
            width += 1
        }
        
        super.init(frame: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(width)))
        
        self.backgroundColor = UIColor.clear
        self.gearColor = gearColor
        self.gear = gear
    }
    
    /// Required initializer
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Drawing methods
    
    /// Override of drawing method
    override public func draw(_ rect: CGRect) {
        _ = CGColorSpaceCreateDeviceRGB()
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext?.clear(rect)
        
        let pitchRadius = gear.pitchDiameter/2
        let outsideRadius = gear.outsideDiameter/2
        let insideRadius = gear.insideDiameter/2
        
        currentContext?.saveGState()
        currentContext?.translateBy(x: rect.width/2, y: rect.height/2)
        currentContext?.addEllipse(in: CGRect(x: -insideRadius/3, y: -insideRadius/3, width: insideRadius*2/3, height: insideRadius*2/3));
        currentContext?.addEllipse(in: CGRect(x: -insideRadius, y: -insideRadius, width: insideRadius*2, height: insideRadius*2));
        currentContext?.setFillColor(self.gearColor.cgColor)
        currentContext?.fillPath(using: .evenOdd)
        
        let angleUtile =  CGFloat(M_PI / (2 * Double(gear.nbTeeth)))
        let angleUtileDemi = angleUtile/2
        
        // In order to draw the teeth quite easily, instead of having complexs calculations,
        // we calcule the needed point for drawing the rightmost horizontal tooth and will rotate the context
        // in order to use the same points
        
        let pointPitchHaut = CGPoint(x: cos(angleUtile) * pitchRadius, y: sin(angleUtile) * pitchRadius)
        let pointPitchBas = CGPoint(x: cos(angleUtile) * pitchRadius, y: -sin(angleUtile) * pitchRadius)
        
        let pointInsideHaut = CGPoint(x: cos(angleUtile) * insideRadius, y: sin(angleUtile) * insideRadius)
        let pointInsideBas = CGPoint(x: cos(angleUtile) * insideRadius, y: -sin(angleUtile) * insideRadius)
        
        let pointOutsideHaut = CGPoint(x: cos(angleUtileDemi) * outsideRadius, y: sin(angleUtileDemi) * outsideRadius)
        let pointOutsideBas = CGPoint(x: cos(angleUtileDemi) * outsideRadius, y: -sin(angleUtileDemi) * outsideRadius)
        
        
        for i in 0..<gear.nbTeeth {
            
            // Saving the context before rotating it
            currentContext?.saveGState()
            
            let gearOriginAngle =  CGFloat((Double(i)) * M_PI * 2 / Double(gear.nbTeeth))
            
            currentContext?.rotate(by: gearOriginAngle)
            
            // Drawing the tooth
            currentContext?.move(to: CGPoint(x: pointInsideHaut.x, y: pointInsideHaut.y))
            currentContext?.addLine(to: CGPoint(x: pointPitchHaut.x, y: pointPitchHaut.y))
            currentContext?.addLine(to: CGPoint(x: pointOutsideHaut.x, y: pointOutsideHaut.y))
            currentContext?.addLine(to: CGPoint(x: pointOutsideBas.x, y: pointOutsideBas.y))
            currentContext?.addLine(to: CGPoint(x: pointPitchBas.x, y: pointPitchBas.y))
            currentContext?.addLine(to: CGPoint(x: pointInsideBas.x, y: pointInsideBas.y))
            currentContext?.fillPath()
            
            // Restoring the context
            currentContext?.restoreGState()
        }
        
        currentContext?.restoreGState()
    }
    
}
