//
//  DemoViewController.swift
//  MAGearRefreshControl-Demo
//
//  Created by Michaël Azevedo on 31/08/2015.
//  Copyright (c) 2015 micazeve. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MAGearRefreshDelegate {
    
    
    //MARK: - Instance properties
    var refreshControlView : MAGearRefreshControl!
    var isLoading = false
    @IBOutlet var myTableView: UITableView!
    
    
    //MARK: - Init methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.delegate = self
        myTableView.dataSource = self
        
        self.navigationController?.navigationBar.translucent = false
        
        
        refreshControlView = MAGearRefreshControl(frame: CGRectMake(0, -self.myTableView.bounds.height, self.view.frame.width, self.myTableView.bounds.height))
        refreshControlView.backgroundColor =  UIColor.initRGB(34, g: 75, b: 150)
        
        refreshControlView.addInitialGear(nbTeeth:12, color: UIColor.initRGB(92, g: 133, b: 236), radius:16)
        refreshControlView.addLinkedGear(0, nbTeeth:16, color: UIColor.initRGB(92, g: 133, b: 236).colorWithAlphaComponent(0.8), angleInDegree: 30)
        refreshControlView.addLinkedGear(0, nbTeeth:32, color: UIColor.initRGB(92, g: 133, b: 236).colorWithAlphaComponent(0.4), angleInDegree: 190)
        refreshControlView.addLinkedGear(1, nbTeeth:40, color: UIColor.initRGB(92, g: 133, b: 236).colorWithAlphaComponent(0.4), angleInDegree: -30)
        refreshControlView.addLinkedGear(2, nbTeeth:24, color: UIColor.initRGB(92, g: 133, b: 236).colorWithAlphaComponent(0.8), angleInDegree: -190)
        refreshControlView.addLinkedGear(3, nbTeeth:10, color: UIColor.initRGB(92, g: 133, b: 236), angleInDegree: 40)
        refreshControlView.setMainGearPhase(0)
        refreshControlView.delegate = self
        refreshControlView.barColor = UIColor.initRGB(92, g: 133, b: 236)
        self.myTableView.addSubview(refreshControlView)
        
    }
    
    //MARK: - Orientation methods
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        refreshControlView.frame = CGRectMake(0, -self.myTableView.bounds.height, self.view.frame.size.width, self.myTableView.bounds.size.height)
    }
    
    
    //MARK: - Various methods
    
    
    
    func refresh(){
        isLoading = true
        
        // -- DO SOMETHING AWESOME (... or just wait 3 seconds) --
        // This is where you'll make requests to an API, reload data, or process information
        var delayInSeconds = 0.6
        var popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            // When done requesting/reloading/processing invoke endRefreshing, to close the control
            self.isLoading = false
            self.refreshControlView.MAGearRefreshScrollViewDataSourceDidFinishedLoading(self.myTableView)
            
        }
        // -- FINISHED SOMETHING AWESOME, WOO! --
    }
    
    
    
    //MARK: - UIScrollViewDelegate protocol conformance
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        refreshControlView.MAGearRefreshScrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        refreshControlView.MAGearRefreshScrollViewDidEndDragging(scrollView)
    }
    
    
    //MARK: - MAGearRefreshDelegate protocol conformance
    
    func MAGearRefreshTableHeaderDataSourceIsLoading(view: MAGearRefreshControl) -> Bool {
        return isLoading
    }
    
    func MAGearRefreshTableHeaderDidTriggerRefresh(view: MAGearRefreshControl) {
        refresh()
    }
    
    
    // MARK: - UITableViewDataSource protocol conformance
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var CellIdentifier = "Cell";
        
        var cell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as? UITableViewCell
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: CellIdentifier)
        }
        
        // Configure the cell...
        cell!.textLabel!.text = "Row \(indexPath.row)"
        
        return cell!
    }
    
    // MARK: - UITableViewDelegate protocol conformance
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    

}
