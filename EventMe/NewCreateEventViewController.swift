//
//  NewCreateEventViewController.swift
//  EventMe
//
//  Created by Charlie Crouse on 12/23/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//

import UIKit

class NewCreateEventViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        //table view elements
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = 70
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    

}
