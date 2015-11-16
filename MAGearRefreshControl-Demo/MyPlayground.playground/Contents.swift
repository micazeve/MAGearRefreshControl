//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"





//MARK: - MAGear Class

/// This class represents a gear in the most abstract way, without any graphical code related.
class MAGear {
    
    //MARK: Instance properties
    
    /// The circle on which two gears effectively mesh, about halfway through the tooth.
    let pitchDiameter:CGFloat
    
    /// Diameter of the gear, measured from the tops of the teeth.
    let outsideDiameter:CGFloat
    
    /// Diameter of the gear, measured at the base of the teeth.
    let insideDiameter:CGFloat
    
    /// The number of teeth per inch of the circumference of the pitch diameter. The diametral pitch of all meshing gears must be the same.
    let diametralPitch:CGFloat
    
    /// Number of teeth of the gear.
    let nbTeeth:UInt
    
    
    //MARK: Init method
    
    /// Init method.
    ///
    /// - parameter radius: of the gear
    /// - parameter nbTeeth: Number of teeth of the gear. Must be greater than 2.
    init (radius:CGFloat, nbTeeth:UInt) {
        
        assert(nbTeeth > 2)
        
        self.pitchDiameter = 2*radius
        self.diametralPitch = CGFloat(nbTeeth)/pitchDiameter
        self.outsideDiameter = CGFloat((nbTeeth+2))/diametralPitch
        self.insideDiameter = CGFloat((nbTeeth-2))/diametralPitch
        self.nbTeeth = nbTeeth
        NSLog("diametralPitch = \(diametralPitch)")
    }
}

//MARK: - MASingleGearView Class

/// This class is used to draw a gear in a UIView.
class MASingleGearView : UIView {
    
    //MARK: Instance properties
    
    /// Gear linked to this view.
    private var gear:MAGear!
    
    /// Color of the gear.
    var gearColor = UIColor.blackColor()
    
    /// Phase of the gear. Varies between 0 and 1.
    /// A phase of 0 represents a gear with the rightmost tooth fully horizontal, while a phase of 0.5 represents a gear with a hole in the rightmost point.
    /// A phase of 1 thus is graphically equivalent to a phase of 0
    var phase:Double = 0
    
    //MARK: Init methods
    
    /// Custom init method
    ///
    /// - parameter gear: Gear linked to this view
    /// - parameter gearColor: Color of the gear
    init(gear:MAGear, gearColor:UIColor) {
        
        var width = Int(gear.outsideDiameter + 1)
        if width%2 == 1 {
            width++
        }
        
        super.init(frame: CGRectMake(0, 0, CGFloat(width), CGFloat(width)))
        
        self.backgroundColor = UIColor.clearColor()
        self.gearColor = gearColor
        self.gear = gear
    }
    
    /// Required initializer
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Drawing methods
    
    /// Override of drawing method
    override func drawRect(rect: CGRect) {
        CGColorSpaceCreateDeviceRGB()
        let currentContext = UIGraphicsGetCurrentContext()
        CGContextClearRect(currentContext, rect)
        
        let pitchRadius = gear.pitchDiameter/2
        let outsideRadius = gear.outsideDiameter/2
        let insideRadius = gear.insideDiameter/2
        
        CGContextSaveGState(currentContext)
        CGContextTranslateCTM(currentContext, rect.width/2, rect.height/2)
        CGContextAddEllipseInRect(currentContext, CGRectMake(-insideRadius/3, -insideRadius/3, insideRadius*2/3, insideRadius*2/3));
        
        CGContextAddEllipseInRect(currentContext, CGRectMake(-insideRadius, -insideRadius, insideRadius*2, insideRadius*2));
        
        
            
            let nbArms = 5
            
            let rayon1 = insideRadius*5/10
            let rayon2 = insideRadius*8/10
            
            let angleBig        = Double(360/nbArms) * M_PI / 180
            let angleSmall      = Double(min(10, 360/nbArms/6)) * M_PI / 180
            
            let originX = rayon1 * CGFloat(cos(angleSmall))
            let originY = -rayon1 * CGFloat(sin(angleSmall))
            
            let finX = sqrt(rayon2*rayon2 - originY*originY)
            
            let angle2 = Double(acos(finX/rayon2))
            
            let originX2 = rayon1 * CGFloat(cos(angleBig - angleSmall))
            let originY2 = -rayon1 * CGFloat(sin(angleBig - angleSmall))
            
            
            for i in 0..<nbArms {
                // Saving the context before rotating it
                CGContextSaveGState(currentContext)
                
                let gearOriginAngle =  CGFloat((Double(i)) * M_PI * 2 / Double(nbArms))
                
                CGContextRotateCTM(currentContext, gearOriginAngle)
                
                CGContextMoveToPoint(currentContext, originX, originY)
                CGContextAddLineToPoint(currentContext, finX, originY)
                
                CGContextAddArc(currentContext, 0, 0, rayon2, -CGFloat(angle2), -CGFloat(angleBig - angle2), 1)
                
                CGContextAddLineToPoint(currentContext, originX2, originY2)
                
                CGContextAddArc(currentContext, 0, 0, rayon1, -CGFloat(angleBig -  angleSmall), -CGFloat(angleSmall), 0)
                CGContextClosePath(currentContext)
                
                CGContextRestoreGState(currentContext)
            }
 
        
        CGContextSetFillColorWithColor(currentContext, self.gearColor.CGColor)
        CGContextEOFillPath(currentContext)
        
        let angleUtile =  CGFloat(M_PI / (2 * Double(gear.nbTeeth)))
        let angleUtileDemi = angleUtile/2
        
        // In order to draw the teeth quite easily, instead of having complexs calculations,
        // we calcule the needed point for drawing the rightmost horizontal tooth and will rotate the context
        // in order to use the same points
        
        let pointPitchHaut = CGPointMake(cos(angleUtile) * pitchRadius, sin(angleUtile) * pitchRadius)
        let pointPitchBas = CGPointMake(cos(angleUtile) * pitchRadius, -sin(angleUtile) * pitchRadius)
        
        let pointInsideHaut = CGPointMake(cos(angleUtile) * insideRadius, sin(angleUtile) * insideRadius)
        let pointInsideBas = CGPointMake(cos(angleUtile) * insideRadius, -sin(angleUtile) * insideRadius)
        
        let pointOutsideHaut = CGPointMake(cos(angleUtileDemi) * outsideRadius, sin(angleUtileDemi) * outsideRadius)
        let pointOutsideBas = CGPointMake(cos(angleUtileDemi) * outsideRadius, -sin(angleUtileDemi) * outsideRadius)
        
        
        for i in 0..<gear.nbTeeth {
        
        // Saving the context before rotating it
        CGContextSaveGState(currentContext)
        
        let gearOriginAngle =  CGFloat((Double(i)) * M_PI * 2 / Double(gear.nbTeeth))
        
        CGContextRotateCTM(currentContext, gearOriginAngle)
        
        // Drawing the tooth
        CGContextMoveToPoint(currentContext, pointInsideHaut.x, pointInsideHaut.y)
        CGContextAddLineToPoint(currentContext, pointPitchHaut.x, pointPitchHaut.y)
        CGContextAddLineToPoint(currentContext, pointOutsideHaut.x, pointOutsideHaut.y)
        CGContextAddLineToPoint(currentContext, pointOutsideBas.x, pointOutsideBas.y)
        CGContextAddLineToPoint(currentContext, pointPitchBas.x, pointPitchBas.y)
        CGContextAddLineToPoint(currentContext, pointInsideBas.x, pointInsideBas.y)
        CGContextFillPath(currentContext)
        
        // Restoring the context
        CGContextRestoreGState(currentContext)
        }
    
        
        CGContextRestoreGState(currentContext)
    }
    
}



let gearView = MASingleGearView(gear: MAGear(radius: 30, nbTeeth: 30), gearColor: UIColor.blackColor())

UIGraphicsBeginImageContextWithOptions(gearView.bounds.size, gearView.opaque, 0.0);


gearView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
let img = UIGraphicsGetImageFromCurrentImageContext()

UIGraphicsEndImageContext();


