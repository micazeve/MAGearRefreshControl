//
//  MAMultiGearView.swift
//  MAGearRefreshControl-Demo
//
//  Created by Michaël Azevedo on 20/02/2017.
//  Copyright © 2017 micazeve. All rights reserved.
//

import UIKit

//MARK: - MAMultiGearView Class

/// This class is used to draw multiples gears in a UIView.
class MAMultiGearView : UIView {
    
    //MARK: Instance properties
    
    /// Left border of the view.
    internal var leftBorderView:UIView = UIView()
    
    /// Right border of the view.
    internal var rightBorderView:UIView = UIView()
    
    /// Margin between the bars and the border of the screen.
    public var barMargin:CGFloat   = 10
    
    /// Width of the bars
    public var barWidth:CGFloat    = 20
    
    /// Color of the side bars
    public var barColor = UIColor.white {
        didSet {
            leftBorderView.backgroundColor   = barColor
            rightBorderView.backgroundColor  = barColor
        }
    }
    
    /// Boolean used to display or hide the side bars.
    public var showBars = true {
        didSet {
            leftBorderView.isHidden   = !showBars
            rightBorderView.isHidden  = !showBars
        }
    }
    
    /// Diametral pitch of the group of gear
    fileprivate var diametralPitch:CGFloat!
    
    /// Array of views of gear
    internal var arrayViews:[MASingleGearView] = []
    
    /// Relations between the gears.
    /// Ex.  arrayRelations[3] = 2   ->    the 3rd gear is linked to the 2nd one.
    internal var arrayRelations:[Int] = [0]
    
    /// Angles between the gears, in degree, according to the unit circle
    /// Ex.  arrayAngles[3] ->   the angle between the 3rd gear and its linked one
    internal var arrayAngles:[Double] = [0]
    
    
    //MARK: Init methods
    
    /// Default initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        
        leftBorderView = UIView(frame:CGRect(x: barMargin, y: 0, width: barWidth, height: frame.height))
        leftBorderView.backgroundColor = barColor
        
        rightBorderView = UIView(frame:CGRect(x: frame.width - barMargin - barWidth, y: 0, width: barWidth, height: frame.height))
        rightBorderView.backgroundColor = barColor
        
        
        addSubview(leftBorderView)
        addSubview(rightBorderView)
    }
    
    /// Required initializer
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Method to add gears
    
    /// Add the initial gear to the view. It is always centered in the view.
    ///
    /// - parameter nbTeeth: Number of teeth of the gear.
    /// - parameter color: Color of the gear.
    /// - parameter radius: Radius in pixel of the gear
    ///
    /// - returns: true if the gear was succesfully created, false otherwise (if at least one gear exists).
    func addInitialGear(nbTeeth:UInt, color: UIColor, radius:CGFloat) -> Bool {
        
        if arrayViews.count > 0  {
            return false
        }
        
        diametralPitch = CGFloat(nbTeeth)/(2*radius)
        
        let gear = MAGear(radius: radius, nbTeeth: nbTeeth)
        
        let view = MASingleGearView(gear: gear, gearColor:color)
        view.phase = 0
        
        view.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        
        arrayViews.append(view)
        self.insertSubview(view, belowSubview: leftBorderView)
        
        return true
    }
    /// Add another gear to the view and link it to another already existing gear
    ///
    /// - parameter gearLinked: Index of the previously created gear
    /// - parameter nbTeeth: Number of teeth of the gear.
    /// - parameter color: Color of the gear.
    /// - parameter angleInDegree: Angle (in degree) between the gear to create and the previous gear, according to the unit circle.
    ///
    /// - returns: true if the gear was succesfully created, false otherwise (if the gearLinked index is incorrect).
    func addLinkedGear(_ gearLinked: Int, nbTeeth:UInt, color:UIColor, angleInDegree:Double) -> Bool {
        
        if gearLinked >= arrayViews.count || gearLinked < 0 {
            return false
        }
        
        let linkedGearView      = arrayViews[gearLinked]
        let linkedGear          = linkedGearView.gear
        
        let newRadius = CGFloat(nbTeeth)/(2*diametralPitch)
        
        let gear = MAGear(radius:newRadius, nbTeeth: nbTeeth)
        
        let dist = Double(gear.pitchDiameter + (linkedGear?.pitchDiameter)!)/2
        
        let xValue = CGFloat(dist*cos(angleInDegree*M_PI/180))
        let yValue = CGFloat(-dist*sin(angleInDegree*M_PI/180))
        
        
        let angleBetweenMainTeethsInDegree = 360/Double((linkedGear?.nbTeeth)!)
        
        let nbDentsPassees = angleInDegree / angleBetweenMainTeethsInDegree
        let phaseForAngle = nbDentsPassees -  Double(Int(nbDentsPassees))
        
        
        var phaseNewGearForAngle = 0.5 + phaseForAngle - linkedGearView.phase
        if gear.nbTeeth%2 == 1 {
            phaseNewGearForAngle += 0.5
        }
        phaseNewGearForAngle = phaseNewGearForAngle - trunc(phaseNewGearForAngle)
        
        let angleBetweenNewTeethsInDegree = 360/Double(gear.nbTeeth)
        let nbNewDentsPassees = angleInDegree / angleBetweenNewTeethsInDegree
        let phaseForNewAngle = 1-(nbNewDentsPassees -  Double(Int(nbNewDentsPassees)))
        
        
        let view = MASingleGearView(gear: gear, gearColor:color)
        view.center = CGPoint(x: linkedGearView.center.x + xValue, y: linkedGearView.center.y + yValue)
        
        arrayRelations.append(gearLinked)
        arrayAngles.append(angleInDegree)
        view.phase = phaseNewGearForAngle - phaseForNewAngle
        
        arrayViews.append(view)
        self.insertSubview(view, belowSubview: leftBorderView)
        return true
    }
    
    
    /// Set the phase for the first gear and calculate it for all the linked gears
    ///
    /// - parameter phase: Phase between 0 and 1 for the first gear.
    func setMainGearPhase(_ phase:Double) {
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
            
            let angleBetweenMainTeethsInDegree = 360/Double((linkedGear?.nbTeeth)!)
            
            let nbDentsPassees = angleInDegree / angleBetweenMainTeethsInDegree
            let phaseForAngle = nbDentsPassees -  Double(Int(nbDentsPassees))
            
            var phaseNewGearForAngle = 0.5 + phaseForAngle - linkedGearView.phase
            if (gear?.nbTeeth)!%2 == 1 {
                phaseNewGearForAngle += 0.5
            }
            phaseNewGearForAngle = phaseNewGearForAngle - trunc(phaseNewGearForAngle)
            
            let angleBetweenNewTeethsInDegree = 360/Double((gear?.nbTeeth)!)
            
            let nbNewDentsPassees = angleInDegree / angleBetweenNewTeethsInDegree
            let phaseForNewAngle = 1-(nbNewDentsPassees -  Double(Int(nbNewDentsPassees)))
            
            
            let finalPhase = phaseNewGearForAngle - phaseForNewAngle
            
            arrayViews[i].phase  = finalPhase
            
            
        }
        for view in arrayViews {
            
            let angleInRad = -view.phase * 2 * M_PI / Double(view.gear.nbTeeth)
            view.transform = CGAffineTransform(rotationAngle: CGFloat(angleInRad))
            
        }
    }
    
    //MARK: View configuration
    
    /// Method used to reset the position of all the gear according to the view frame. Is used principally when the frame is changed
    internal func configureView()
    {
        if arrayViews.count == 0 {
            return
        }
        
        arrayViews[0].center.x = frame.size.width/2
        arrayViews[0].center.y = frame.height/2
        
        
        for i in 1..<arrayViews.count {
            
            let angleBetweenGears = arrayAngles[i]
            
            let gearView = arrayViews[i]
            let gear = gearView.gear
            
            
            let linkedGearView      = arrayViews[arrayRelations[i]]
            let linkedGear          = linkedGearView.gear
            let dist = Double((gear?.pitchDiameter)! + (linkedGear?.pitchDiameter)!)/2
            let xValue = CGFloat(dist*cos(angleBetweenGears*M_PI/180))
            let yValue = CGFloat(-dist*sin(angleBetweenGears*M_PI/180))
            
            gearView.center = CGPoint(x: linkedGearView.center.x + xValue, y: linkedGearView.center.y + yValue)
            
            arrayViews[i].gear = gear
            
        }
        
        leftBorderView.frame    = CGRect(x: 10,  y: 0, width: barWidth, height: frame.height)
        rightBorderView.frame   = CGRect(x: frame.size.width - 10 - barWidth, y: 0, width: barWidth, height: frame.height)
        
    }
    
    //MARK: Override setFrame
    
    override var frame:CGRect  {
        didSet {
            configureView()
        }
    }
    
}
