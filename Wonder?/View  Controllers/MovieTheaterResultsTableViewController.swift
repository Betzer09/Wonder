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
        guard let count = MovieController.shared.recommendedTheaterMoviesToDisplayToTheUser?.count else {return 1}
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieTheaterResultsCell", for: indexPath)
        
        guard let theaterMovies = MovieController.shared.recommendedTheaterMoviesToDisplayToTheUser else {return UITableViewCell()}
        
        let movie = theaterMovies[indexPath.row]
        cell.textLabel?.text = movie.title
        cell.detailTextLabel?.text = movie.releaseDate
        
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
