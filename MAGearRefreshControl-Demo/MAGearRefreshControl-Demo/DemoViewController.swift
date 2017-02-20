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
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        
        refreshControlView = MAGearRefreshControl(frame: CGRect(x: 0, y: -self.myTableView.bounds.height, width: self.view.frame.width, height: self.myTableView.bounds.height))
        refreshControlView.backgroundColor =  UIColor.initRGB(34, g: 75, b: 150)
        
        _ = refreshControlView.addInitialGear(nbTeeth:12, color: UIColor.initRGB(92, g: 133, b: 236), radius:16)
        _ = refreshControlView.addLinkedGear(0, nbTeeth:16, color: UIColor.initRGB(92, g: 133, b: 236).withAlphaComponent(0.8), angleInDegree: 30)
        _ = refreshControlView.addLinkedGear(0, nbTeeth:32, color: UIColor.initRGB(92, g: 133, b: 236).withAlphaComponent(0.4), angleInDegree: 190, gearStyle: .WithBranchs)
        _ = refreshControlView.addLinkedGear(1, nbTeeth:40, color: UIColor.initRGB(92, g: 133, b: 236).withAlphaComponent(0.4), angleInDegree: -30, gearStyle: .WithBranchs, nbBranches:12)
        _ = refreshControlView.addLinkedGear(2, nbTeeth:24, color: UIColor.initRGB(92, g: 133, b: 236).withAlphaComponent(0.8), angleInDegree: -190)
        _ = refreshControlView.addLinkedGear(3, nbTeeth:10, color: UIColor.initRGB(92, g: 133, b: 236), angleInDegree: 40)
        refreshControlView.setMainGearPhase(0)
        refreshControlView.delegate = self
        refreshControlView.barColor = UIColor.initRGB(92, g: 133, b: 236)
        self.myTableView.addSubview(refreshControlView)
        
    }
    
    //MARK: - Orientation methods
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        refreshControlView.frame = CGRect(x: 0, y: -self.myTableView.bounds.height, width: self.view.frame.size.width, height: self.myTableView.bounds.size.height)
    }
    
    
    //MARK: - Various methods
    
    
    
    func refresh(){
        isLoading = true
        
        // -- DO SOMETHING AWESOME (... or just wait 3 seconds) --
        // This is where you'll make requests to an API, reload data, or process information
        let delayInSeconds = 0.6
        let popTime = DispatchTime.now() + Double(Int64(delayInSeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) { () -> Void in
            // When done requesting/reloading/processing invoke endRefreshing, to close the control
            self.isLoading = false
            self.refreshControlView.MAGearRefreshScrollViewDataSourceDidFinishedLoading(self.myTableView)
            
        }
        // -- FINISHED SOMETHING AWESOME, WOO! --
    }
    
    
    
    //MARK: - UIScrollViewDelegate protocol conformance
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        refreshControlView.MAGearRefreshScrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        refreshControlView.MAGearRefreshScrollViewDidEndDragging(scrollView)
    }
    
    
    //MARK: - MAGearRefreshDelegate protocol conformance
    
    func MAGearRefreshTableHeaderDataSourceIsLoading(_ view: MAGearRefreshControl) -> Bool {
        return isLoading
    }
    
    func MAGearRefreshTableHeaderDidTriggerRefresh(_ view: MAGearRefreshControl) {
        refresh()
    }
    
    
    // MARK: - UITableViewDataSource protocol conformance
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "Cell";
        
        var cell: AnyObject? = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: CellIdentifier)
        }
        
        // Configure the cell...
        cell!.textLabel!!.text = "Row \(indexPath.row)"
        
        return cell as! UITableViewCell!
    }
    
    // MARK: - UITableViewDelegate protocol conformance
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    

}
