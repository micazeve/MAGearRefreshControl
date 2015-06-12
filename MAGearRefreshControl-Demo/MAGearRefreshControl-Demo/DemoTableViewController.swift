//
//  DemoTableViewController.swift
//  MAGearRefreshControl-Demo
//
//  Created by Michaël Azevedo on 20/05/2015.
//  Copyright (c) 2015 micazeve. All rights reserved.
//

import UIKit

class DemoTableViewController: UITableViewController, MAGearRefreshDelegate {
    
    //MARK: - Instance properties
    var refreshControlView : MAGearRefreshControl!
    var isLoading = false
    
    //MARK: - Init methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.translucent = false
        
        
        refreshControlView = MAGearRefreshControl(frame: CGRectMake(0, -self.tableView.bounds.height, self.view.frame.width, self.tableView.bounds.height))
        refreshControlView.backgroundColor =  UIColor.initRGB(34, g: 75, b: 150)
        
        refreshControlView.addInitialGear(nbTeeth:12, color: UIColor(white: 0.85, alpha: 1), radius:15)
        refreshControlView.addLinkedGear(0, nbTeeth:20, color: UIColor(white: 0.955, alpha: 1), angleInDegree: 30)
        refreshControlView.addLinkedGear(1, nbTeeth:40, color: UIColor(white: 0.965, alpha: 1), angleInDegree: -30)
        refreshControlView.addLinkedGear(2, nbTeeth:10, color: UIColor(white: 0.94, alpha: 1), angleInDegree: 40)
        refreshControlView.setMainGearPhase(0)
        refreshControlView.barColor = UIColor.initRGB(198, g: 198, b: 205).colorWithAlphaComponent(0.5)
        refreshControlView.delegate = self
        refreshControlView.barColor = UIColor.initRGB(92, g: 133, b: 236)
        self.tableView.addSubview(refreshControlView)
        
    }
    
    //MARK: - Orientation methods
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        refreshControlView.frame = CGRectMake(0, -self.tableView.bounds.height, self.view.frame.size.width, self.tableView.bounds.size.height)
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
            self.refreshControlView.MAGearRefreshScrollViewDataSourceDidFinishedLoading(self.tableView)
            
        }
        // -- FINISHED SOMETHING AWESOME, WOO! --
    }
    
    
    
    //MARK: - UIScrollViewDelegate protocol conformance
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        refreshControlView.MAGearRefreshScrollViewDidScroll(scrollView)
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
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
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
}