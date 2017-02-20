//
//  MAGearRefreshControl.swift
//
//  Created by Michaël Azevedo on 20/05/2015.
//  Copyright (c) 2015 micazeve. All rights reserved.
//

import UIKit


///MARK: - MAGearRefreshDelegate protocol


/// Protocol between the MAGearRefreshControl and its delegate (mostly UITableViewController).
 @objc public protocol MAGearRefreshDelegate {

    /// Method called when the pull to refresh move was triggered.
    ///
    /// - parameter view: The MAGearRefreshControl object.
    func MAGearRefreshTableHeaderDidTriggerRefresh(_ view:MAGearRefreshControl)
    
    /// Method called to know if the data source is loading or no
    ///
    /// - parameter view: The MAGearRefreshControl object.
    ///
    /// - returns: true if the datasource is loading, false otherwise
    func MAGearRefreshTableHeaderDataSourceIsLoading(_ view:MAGearRefreshControl) -> Bool
}




//MARK: - MAGearRefreshControl Class

/// This class is used to draw an animated group of gears and offers the same interactions as an UIRefreshControl
public class MAGearRefreshControl: MAAnimatedMultiGearView {
    
    //MARK: Instance properties
    
    /// Enum representing the different state of the refresh control
    public enum MAGearRefreshState: UInt8 {
        case normal         // The user is pulling but hasn't reach the activation threshold yet
        case pulling        // The user is still pulling and has passed the activation threshold
        case loading        // The refresh control is animating
    }
    
    /// State of the refresh control
    fileprivate var state = MAGearRefreshState.normal
    
    /// Delegate conforming to the MAGearRefreshDelegate protocol. Most of time it's an UITableViewController
    public var delegate:MAGearRefreshDelegate?
    
    /// Content offset of the tableview
    fileprivate var contentOffset:CGFloat = 0
    
    /// Variable used to allow the end of the refresh
    /// We must wait for the end of the animation of the contentInset before allowing the refresh
    fileprivate var endRefreshAllowed = false
    
    /// Variable used to know if the end of the refresh has been asked
    fileprivate var endRefreshAsked = false
    
    
    
    
    //MARK: Various methods
    
    /// Set the state of the refresh control.
    ///
    /// - parameter aState: New state of the refresh control.
    fileprivate func setState(_ aState:MAGearRefreshState) {
        NSLog("setState : \(aState.rawValue)")
        switch aState {
            
        case .loading:
            self.rotate()
            if style == .singleGear {
                
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    for i in 1..<self.arrayViews.count {
                        self.arrayViews[i].alpha = 0
                        
                    } }, completion:nil)
            }
            
            break
        default:
            break
        }
        state = aState
    }
    
    
    //MARK: Public methods
    
    /// Method to call when the scrollview was scrolled.
    ///
    /// - parameter scrollView: The scrollview.
    public func MAGearRefreshScrollViewDidScroll(_ scrollView:UIScrollView) {
        
        configureWithContentOffsetY(-scrollView.contentOffset.y)
        
        if (state == .loading) {
            
            var offset = max(scrollView.contentOffset.y * -1, 0)
            offset = min(offset, 60)
            scrollView.contentInset = UIEdgeInsetsMake(offset, 0, 0, 0)
            
        } else {
            if (scrollView.isDragging) {
                
                var loading = false
                
                if let load = delegate?.MAGearRefreshTableHeaderDataSourceIsLoading(self) {
                    loading = load
                }
                
                if state == .pulling && scrollView.contentOffset.y > -65 && scrollView.contentOffset.y < 0 && !loading {
                    setState(.normal)
                } else if state == .normal && scrollView.contentOffset.y < -65 && !loading {
                    setState(.pulling)
                }
                
                
                if (scrollView.contentInset.top != 0) {
                    scrollView.contentInset = UIEdgeInsets.zero;
                }
            }
            
             let phase = -Double(scrollView.contentOffset.y/20)
            
            if stopRotation {
                setMainGearPhase(phase)
            }
        }
    }
    
    /// Method to call when the scrollview ended dragging
    ///
    /// - parameter scrollView: The scrollview.
    public func MAGearRefreshScrollViewDidEndDragging(_ scrollView:UIScrollView) {
        
        NSLog("MAGearRefreshScrollViewDidEndDragging")
        /*if state == .Loading {
            NSLog("return")
            return
        }*/
        
        var loading = false
        
        if let load = delegate?.MAGearRefreshTableHeaderDataSourceIsLoading(self) {
            loading = load
        }
        
        if scrollView.contentOffset.y <= -65.0 && !loading {
            
            self.stopRotation = false
            delegate?.MAGearRefreshTableHeaderDidTriggerRefresh(self)
            
            setState(.loading)
            
            let contentOffset = scrollView.contentOffset
            
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
               
                scrollView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0)
                scrollView.contentOffset = contentOffset;          // Workaround for smooth transition on iOS8
                }, completion: { (completed) -> Void in
                    NSLog("completed")
                    let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.6 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                        // your function here
                        self.endRefreshAllowed = true
                        if self.endRefreshAsked {
                            NSLog("self.endRefreshAsked")
                            self.endRefreshAsked = false
                            self.MAGearRefreshScrollViewDataSourceDidFinishedLoading(scrollView)
                        }
                    })
                    
                    
            })
            
        }
    }
    
    /// Method to call when the datasource finished loading
    ///
    /// - parameter scrollView: The scrollview.
    public func MAGearRefreshScrollViewDataSourceDidFinishedLoading(_ scrollView:UIScrollView) {
        
        NSLog("MAGearRefreshScrollViewDataSourceDidFinishedLoading")
        
        if !endRefreshAllowed {
            endRefreshAsked = true
            return
        }
        endRefreshAllowed = false
        self.setState(.normal)
        
        scrollView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.arrayViews[0].transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: { (finished) -> Void in
                
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    
                    if self.style == .keepGears {
                        for i in 1..<self.arrayViews.count {
                            self.arrayViews[i].alpha = 0
                        }
                    }
                    
                    
                    self.arrayViews[0].transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                })
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveLinear, animations: { () -> Void in
                    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                    scrollView.contentOffset = CGPoint(x: 0, y: 0);          // Workaround for smooth transition on iOS8
                    }, completion: { (finished) -> Void in
                        self.stopRotation = true
                        scrollView.isUserInteractionEnabled = true
                        for view in self.arrayViews {
                            view.alpha = 1
                            view.transform = CGAffineTransform.identity
                            
                        }
                })
        }) 
    }
    
    
    //MARK: View configuration
    
    /// Method to configure the view with an Y offset of the scrollview
    ///
    /// - parameter offset: Offset of the scrollView
    fileprivate func configureWithContentOffsetY(_ offset:CGFloat)
    {
        contentOffset = offset
        configureView()
    }
    
    /// Override of configureView(). The override is needed since we don't want the first gear to be centered within the view.
    /// Instead, we want it to be centered within the visible part of the view
    override internal func configureView() {
        if arrayViews.count == 0 {
            return
        }
        
        arrayViews[0].center.x = frame.size.width/2
        arrayViews[0].center.y = frame.height  - contentOffset/2
        
        
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
        
        leftBorderView.frame    = CGRect(x: barMargin, y: frame.height - contentOffset, width: barWidth, height: contentOffset)
        rightBorderView.frame   = CGRect(x: frame.size.width - barMargin - barWidth, y: frame.height - contentOffset, width: barWidth, height: contentOffset)
    }
    
    //MARK: Public methods override
    
    /// Override of startRotating in order to disable this portion of code (must be triggered from the tableview)
    override public func startRotating() {
        
    }
    
    /// Override of stopRotating in order to disable this portion of code (must be triggered from delegate)
    override public func stopRotating()
    {
    }
}
