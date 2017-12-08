//
//  MovieTheaterResultsTableViewController.swift
//  Wonder?
//
//  Created by Austin Betzer on 12/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class MovieTheaterResultsTableViewController: UITableViewController {

    // MARK: - Properties
    
    
    // MARK: - View LifeCycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        navigationItem.leftBarButtonItem?.action = #selector(presentMovieVC)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Try Again", style: .done, target: self, action: #selector(presentMovieVC))
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    @objc func presentMovieVC() {
        self.performSegue(withIdentifier: "toMovieTBVC", sender: self)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieTheaterResultsCell", for: indexPath)
        
        
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
}
