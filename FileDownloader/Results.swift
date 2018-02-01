//
//  Results.swift
//  FileDownloader
//
//  Created by Victoria Hawkins on 1/31/18.
//  Copyright © 2018 Victoria Hawkins. All rights reserved.
//

import UIKit

class Results: UITableViewController {

    var pageResultsAndCounts:[(String, Int)] = []

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none


    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // return 1 or numberofrowsinsection is not called and view will not display
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return pageResultsAndCounts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "pageResultsCell"

        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        // Configure the cell...
        let (page, count) = pageResultsAndCounts[indexPath.row]

        cell.textLabel?.text = page
        cell.detailTextLabel?.text = String(count)

        return cell
    }
 


}
