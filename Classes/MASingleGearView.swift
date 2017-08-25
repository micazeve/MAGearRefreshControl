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
    
   /// Enum representing the style of the Gear
    public enum MAGearStyle: UInt8 {
        case Normal         // Default style, full gear
        case WithBranchs    // With `nbBranches` inside the gear
    }
   
    /// Style of the gear
    let style:MAGearStyle
    
    /// Number of branches inside the gear.
    /// Ignored if style == .Normal.
    /// Default value is 5.
    let nbBranches:UInt
    
    //MARK: Init methods
    
    /// Custom init method
    ///
    /// - parameter gear: Gear linked to this view
    /// - parameter gearColor: Color of the gear 
    /// - parameter style: Style of the gear
    /// - parameter nbBranches: Number of branches if the gear style is 'WithBranches'
    
    public init(gear:MAGear, gearColor:UIColor, style:MAGearStyle = .Normal, nbBranches:UInt = 5) {
        
        var width = Int(gear.outsideDiameter + 1)
        if width%2 == 1 {
            width += 1
        }
        
        self.style = style
        self.gearColor = gearColor
        self.nbBranches = nbBranches
        self.gear = gear
        
        super.init(frame: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(width)))
        
        self.backgroundColor = UIColor.clear
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
        
        
        if style == .WithBranchs {
            
            let rayon1 = insideRadius*5/10
            let rayon2 = insideRadius*8/10
            
            let angleBig        = Double(360/nbBranches) * Double.pi / 180
            let angleSmall      = Double(min(10, 360/nbBranches/6)) * Double.pi / 180
            
            let originX = rayon1 * CGFloat(cos(angleSmall))
            let originY = -rayon1 * CGFloat(sin(angleSmall))
            
            let finX = sqrt(rayon2*rayon2 - originY*originY)
            
            let angle2 = Double(acos(finX/rayon2))
            
            let originX2 = rayon1 * CGFloat(cos(angleBig - angleSmall))
            let originY2 = -rayon1 * CGFloat(sin(angleBig - angleSmall))
            
            
            for i in 0..<nbBranches {
                // Saving the context before rotating it
                currentContext?.saveGState()
                
                let gearOriginAngle =  CGFloat((Double(i)) * Double.pi * 2 / Double(nbBranches))
                
                currentContext?.rotate(by: gearOriginAngle)
                currentContext?.move(to: CGPoint(x: originX, y: originY))
                currentContext?.addLine(to: CGPoint(x: finX, y: originY))
                currentContext?.addArc(center: CGPoint.zero, radius: rayon2, startAngle: -CGFloat(angle2), endAngle: -CGFloat(angleBig - angle2), clockwise: true)
                
                currentContext?.addLine(to: CGPoint(x: originX2, y: originY2))
                
                currentContext?.addArc(center: CGPoint.zero, radius: rayon1, startAngle: -CGFloat(angleBig -  angleSmall), endAngle: -CGFloat(angleSmall), clockwise: false)
                currentContext?.closePath()
                
                currentContext?.restoreGState()
            }
        }
        
        
        currentContext?.setFillColor(self.gearColor.cgColor)
        currentContext?.fillPath(using: .evenOdd)
        
        let angleUtile =  CGFloat(Double.pi / (2 * Double(gear.nbTeeth)))
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
            
            let gearOriginAngle =  CGFloat((Double(i)) * Double.pi * 2 / Double(gear.nbTeeth))
            
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
