//
//  MAGearRefreshControl.swift
//
//  Created by Michaël Azevedo on 20/05/2015.
//  Copyright (c) 2015 micazeve. All rights reserved.
//

import UIKit





@objc protocol MAGearRefreshDelegate {
    func MAGearRefreshTableHeaderDidTriggerRefresh(view:MAGearRefreshControl)
    func MAGearRefreshTableHeaderDataSourceIsLoading(view:MAGearRefreshControl) -> Bool
}






/// Multiplicator factor in order to draw the gear correctly. Was set arbitrarily and can be changed.
let multRadius:UInt = 60


//MARK: - Gear Class

/// This class represents a gear in the most abstract way, without any graphical code related.
class Gear {
    
    //MARK: Instance properties
    
    /// The circle on which two gears effectively mesh, about halfway through the tooth.
    let pitchDiameter:CGFloat
    
    /// Diameter of the gear, measured from the tops of the teeth.
    let outsideDiameter:CGFloat
    
    /// Diameter of the gear, measured at the base of the teeth.
    let insideDiameter:CGFloat
    
    /// The number of teeth per inch of the circumference of the pitch diameter. The diametral pitch of all meshing gears must be the same.
    let diametralPitch:UInt
    
    /// Number of teeth of the gear.
    let nbTeeth:UInt
    
    
    //MARK: Init method
    
    /// Init method.
    ///
    /// :param: diametralPitch Diametral pitch of the group of gears
    /// :param: nbTeeth Number of teeth of the gear. Must be greater than 2.
    init (diametralPitch:UInt, nbTeeth:UInt) {
        
        assert(nbTeeth > 2)
        
        self.diametralPitch = diametralPitch
        self.pitchDiameter = CGFloat(multRadius*nbTeeth)/CGFloat(diametralPitch)
        self.outsideDiameter = CGFloat(multRadius*(nbTeeth+2))/CGFloat(diametralPitch)
        self.insideDiameter = CGFloat(multRadius*(nbTeeth-2))/CGFloat(diametralPitch)
        self.nbTeeth = nbTeeth
    }
}

//MARK: - SingleGearView Class

/// This class is used to draw a gear in a UIView.
class SingleGearView : UIView {
    
    //MARK: Instance properties
    
    /// Gear linked to this view.
    var gear:Gear! = nil
    
    /// Color of the gear.
    var gearColor = UIColor.blackColor()
    
    /// Phase of the gear. Varies between 0 and 1.
    /// A phase of 0 represents a gear with the rightmost tooth fully horizontal, while a phase of 0.5 represents a gear with a hole in the rightmost point.
    /// A phase of 1 thus is graphically equivalent to a phase of 0
    var phase:Double = 0
    
    //MARK: Init methods
    
    /// Custom init method
    ///
    /// :param: gear Gear linked to this view
    /// :param: gearColor Color of the gear
    init(gear:Gear, gearColor:UIColor) {
        
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
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Drawing methods
    
    /// Override of drawing method
    override func drawRect(rect: CGRect) {
        let baseSpace = CGColorSpaceCreateDeviceRGB()
        let currentContext = UIGraphicsGetCurrentContext()
        CGContextClearRect(currentContext, rect)
        
        let pitchRadius = gear.pitchDiameter/2
        let outsideRadius = gear.outsideDiameter/2
        let insideRadius = gear.insideDiameter/2
        
        CGContextSaveGState(currentContext)
        CGContextTranslateCTM(currentContext, rect.width/2, rect.height/2)
        CGContextAddEllipseInRect(currentContext, CGRectMake(-insideRadius/3, -insideRadius/3, insideRadius*2/3, insideRadius*2/3));
        CGContextAddEllipseInRect(currentContext, CGRectMake(-insideRadius, -insideRadius, insideRadius*2, insideRadius*2));
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



//MARK: - MAGearRefreshControl Class

/// This class is used to draw a group of gear and offers the same interactions as an UIRefreshControl

class MAGearRefreshControl: UIView {
    
    
    enum MAGearRefreshState: UInt8 {
        case Pulling
        case Normal
        case Loading
    }
    
    var delegate:MAGearRefreshDelegate?
    var state = MAGearRefreshState.Normal
    

    let barreWidth:CGFloat = 20
    var diametralPitch:UInt = 24
    
    var arrayViews:[SingleGearView] = []
    var arrayBorders:[UIView] = []
    
    /// Relations between the gears.
    /// Ex.  arrayRelations[3] = 2   ->    the 3rd gear is linked to the 2nd one.
    var arrayRelations:[Int] = [0]
    
    /// Angles between the gears, in degree, according to the unit circle
    /// Ex.  arrayAngles[3] ->   the angle between the 3rd gear and its linked one
    var arrayAngles:[Double] = [0]
    
    var lastContentOffset:CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        
        let view1 = UIView(frame:CGRectMake(10, 0, barreWidth, frame.height))
        view1.backgroundColor = UIColor.initRGB(92, g: 133, b: 236)
        
        
        let view2 = UIView(frame:CGRectMake(frame.width - 10 - barreWidth, 0, barreWidth, frame.height))
        view2.backgroundColor = UIColor.initRGB(92, g: 133, b: 236)
        
        arrayBorders = [view1, view2]
        
        addSubview(view1)
        addSubview(view2)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
        
    func setState(aState:MAGearRefreshState) {
        
        switch aState {
            
        case .Pulling:
            break
            
        case .Normal:
            
            if state != .Normal {
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    for i in 1..<self.arrayViews.count {
                        self.arrayViews[i].alpha = 1
                        
                    } }, completion:nil)
            }
         
            break
            
        case .Loading:
            self.rotate()
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                for i in 1..<self.arrayViews.count {
                    self.arrayViews[i].alpha = 0
                    
                } }, completion:nil)
            break
        default:
            break
        }
        state = aState
    }
    
    
    func rotate() {
        
        var rotate = true
        if let rot = delegate?.MAGearRefreshTableHeaderDataSourceIsLoading(self) {
            rotate = rot
        }
        
        if rotate {
            UIView.animateWithDuration(1, delay: 0, options: .CurveLinear, animations: { () -> Void in
                self.arrayViews[0].transform = CGAffineTransformRotate(self.arrayViews[0].transform, CGFloat(M_PI))
                }, completion: { (finished) -> Void in
                    self.rotate()
            })
        }
    }
    

    func MAGearRefreshScrollViewDidScroll(scrollView:UIScrollView) {
        
        configureWithContentOffsetY(-scrollView.contentOffset.y)
        
        if (state == .Loading) {
            
            var offset = max(scrollView.contentOffset.y * -1, 0)
            offset = min(offset, 60)
            scrollView.contentInset = UIEdgeInsetsMake(offset, 0, 0, 0)
            
        } else {
            if (scrollView.dragging) {
                              
                var loading = false
                
                if let load = delegate?.MAGearRefreshTableHeaderDataSourceIsLoading(self) {
                    loading = load
                }
                
                if state == .Pulling && scrollView.contentOffset.y > -65 && scrollView.contentOffset.y < 0 && !loading {
                    setState(.Normal)
                } else if state == .Normal && scrollView.contentOffset.y < -65 && !loading {
                    setState(.Pulling)
                }
                
                
                if (scrollView.contentInset.top != 0) {
                    scrollView.contentInset = UIEdgeInsetsZero;
                }
            }
            var phase = -Double(scrollView.contentOffset.y/20)
            phase -= Double(Int(phase))
            setMainGearPhase(phase)
        }
    }
    
    func MAGearRefreshScrollViewDidEndDragging(scrollView:UIScrollView) {
        var loading = false
        
        if let load = delegate?.MAGearRefreshTableHeaderDataSourceIsLoading(self) {
            loading = load
        }
        
        if scrollView.contentOffset.y <= -65.0 && !loading {
            
            
            delegate?.MAGearRefreshTableHeaderDidTriggerRefresh(self)
            
            setState(.Loading)
            
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.2)
            scrollView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0)
            UIView.commitAnimations()
            
        }
    }
    
    func MAGearRefreshScrollViewDataSourceDidFinishedLoading(scrollView:UIScrollView) {
        
        
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.arrayViews[0].transform = CGAffineTransformMakeScale(1.2, 1.2)
        }) { (finished) -> Void in
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.arrayViews[0].transform = CGAffineTransformMakeScale(0.1, 0.1)
                })
            
            UIView.animateWithDuration(0.3, delay: 0.1, options: .CurveLinear, animations: { () -> Void in
                scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            }, completion: { (finished) -> Void in
                self.setState(.Normal)
            })
        }
    }
    
    
    func addInitialGear(#nbTeeth:UInt, color: UIColor) {
        
        if arrayViews.count > 0  {
            return
        }
        
        let gear = Gear(diametralPitch: diametralPitch, nbTeeth: nbTeeth)

        let view = SingleGearView(gear: gear, gearColor:color)
        view.phase = 0
        
        addSubview(view)
        
        view.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
        
        arrayViews.append(view)
        
        for border in arrayBorders {
            self.bringSubviewToFront(border)
        }
        
    }
    
    func addLinkedGear(gearLinked: Int, nbTeeth:UInt, color:UIColor, angleInDegree:Double) {
        
        
        if gearLinked >= arrayViews.count {
            return
        }
        
        let linkedGearView      = arrayViews[gearLinked]
        let linkedGear          = linkedGearView.gear
        
        let gear = Gear(diametralPitch: diametralPitch, nbTeeth: nbTeeth)
        
        let dist = Double(gear.pitchDiameter + linkedGear.pitchDiameter)/2
        
        let xValue = CGFloat(dist*cos(angleInDegree*M_PI/180))
        let yValue = CGFloat(-dist*sin(angleInDegree*M_PI/180))

        
        var angleBetweenMainTeethsInDegree = 360/Double(linkedGear.nbTeeth)
        
        var nbDentsPassees = angleInDegree / angleBetweenMainTeethsInDegree
        var phaseForAngle = nbDentsPassees -  Double(Int(nbDentsPassees))
        
        
        var phaseNewGearForAngle = 0.5 + phaseForAngle - linkedGearView.phase
        
        if phaseNewGearForAngle >= 1 {
            phaseNewGearForAngle -= 1
        }
        
        
        
        var angleBetweenNewTeethsInDegree = 360/Double(gear.nbTeeth)
        
        var nbNewDentsPassees = angleInDegree / angleBetweenNewTeethsInDegree
        var phaseForNewAngle = 1-(nbNewDentsPassees -  Double(Int(nbNewDentsPassees)))
        
        
        
        let view = SingleGearView(gear: gear, gearColor:color)
        addSubview(view)
        view.center = CGPointMake(linkedGearView.center.x + xValue, linkedGearView.center.y + yValue)
        
        arrayRelations.append(gearLinked)
        arrayAngles.append(angleInDegree)
        view.phase = phaseNewGearForAngle - phaseForNewAngle
        
        
        arrayViews.append(view)
        for border in arrayBorders {
            self.bringSubviewToFront(border)
        }
        
    }
    
    func setMainGearPhase(phase:Double) {
        if arrayViews.count == 0  {
            return
        }
        
        var newPhase = phase
        if newPhase >= 1 {
            newPhase = 0
        } else if newPhase < 0 {
            newPhase = 0
        }
        
        arrayViews[0].phase = newPhase
        
        for i in 1..<arrayViews.count {
            
            let gearView = arrayViews[i]
            
       
            let gear                = gearView.gear
            let linkedGearView      = arrayViews[arrayRelations[i]]
            let linkedGear          = linkedGearView.gear
            
            
            let angleInDegree = arrayAngles[i]
            
            let angleBetweenMainTeethsInDegree = 360/Double(linkedGear.nbTeeth)
            
            let nbDentsPassees = angleInDegree / angleBetweenMainTeethsInDegree
            var phaseForAngle = nbDentsPassees -  Double(Int(nbDentsPassees))
            
            
            var phaseNewGearForAngle = 0.5 + phaseForAngle - linkedGearView.phase
            
            if phaseNewGearForAngle >= 1 {
                phaseNewGearForAngle -= 1
            }
            var angleBetweenNewTeethsInDegree = 360/Double(gear.nbTeeth)
            
            var nbNewDentsPassees = angleInDegree / angleBetweenNewTeethsInDegree
            var phaseForNewAngle = 1-(nbNewDentsPassees -  Double(Int(nbNewDentsPassees)))
            
            
            let finalPhase = phaseNewGearForAngle - phaseForNewAngle
            
            arrayViews[i].phase  = finalPhase
         
            
        }
        for view in arrayViews {
            
            let angleInRad = -view.phase * 2 * M_PI / Double(view.gear.nbTeeth)
            view.transform = CGAffineTransformMakeRotation(CGFloat(angleInRad))
      
        }
    }
    
    override var frame:CGRect  {
        didSet {
            // You can use 'oldValue' to see what it used to be,
            // and 'highlighted' will be what it was set to.
            configureWithContentOffsetY(lastContentOffset)
        }
    }
    

    func configureWithContentOffsetY(offset:CGFloat)
    {
        if arrayViews.count == 0 {
            return
        }
        
        lastContentOffset = offset
        arrayViews[0].center.x = frame.size.width/2
        arrayViews[0].center.y = frame.height - offset/2
        
        for i in 1..<arrayViews.count {
            
            let angleBetweenGears = arrayAngles[i]
            
            let gearView = arrayViews[i]
            let gear = gearView.gear
            
            
            let linkedGearView      = arrayViews[arrayRelations[i]]
            let linkedGear          = linkedGearView.gear
            let dist = Double(gear.pitchDiameter + linkedGear.pitchDiameter)/2
            let xValue = CGFloat(dist*cos(angleBetweenGears*M_PI/180))
            let yValue = CGFloat(-dist*sin(angleBetweenGears*M_PI/180))
            
            gearView.center = CGPointMake(linkedGearView.center.x + xValue, linkedGearView.center.y + yValue)
            
            arrayViews[i].gear = gear
            
        }
        
        arrayBorders[0].frame = CGRectMake(10, frame.height - offset, barreWidth, offset)
        arrayBorders[1].frame = CGRectMake(frame.size.width - 10 - barreWidth, frame.height - offset, barreWidth, offset)
        
    }
    
}
