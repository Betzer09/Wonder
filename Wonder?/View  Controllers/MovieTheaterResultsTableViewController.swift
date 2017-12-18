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
    var trailors: [MovieTrailers.MovieTrailor] = []
    
    // MARK: - View LifeCycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Try Again", style: .done, target: self, action: #selector(presentMovieVC))
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Actions
    @objc func presentMovieVC() {
        self.performSegue(withIdentifier: "toMovieTBVC", sender: self)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let count = MovieController.shared.recommendedTheaterMoviesToDisplayToTheUser?.count else {return 1}
        return 3
    }
    
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 215
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "movieTheaterResultsCell", for: indexPath) as? TheaterMovieTableViewCell else {return UITableViewCell()}
        
        guard let theaterMovies = MovieController.shared.recommendedTheaterMoviesToDisplayToTheUser else {return UITableViewCell()}
        cell.backgroundColor = UIColor.clear
        let movie = theaterMovies[indexPath.row]
        cell.updateCellWith(theaterMovie: movie)
        
        return cell
    }
    
    // MARK: - Functions
    
    func configureUI() {
        guard let theaterMovies = MovieController.shared.recommendedTheaterMoviesToDisplayToTheUser else {return}
        let group = DispatchGroup()
        for movie in theaterMovies {
            group.enter()
            // fetch the movie with the id
            
            guard let index = MovieController.shared.moviesThatAreSmilar.index(where: { $0.title == movie.title } ) else {
                group.leave()
                return
            }
            
            let movieDB = MovieController.shared.moviesThatAreSmilar[index]
            MovieTrailorController.shared.fetchMovieTrailorWith(movie: movieDB.id, completion: { (trailors) in
                if trailors.count == 0 {
                    group.leave()
                    return
                }
                
                self.trailors += trailors
            })
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            print("Done fetching trailor data")
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMovieDetail" {
            guard let destination = segue.destination as? MovieDetailViewController, let indexPath = tableView.indexPathForSelectedRow else {return}
            
            
            guard let theaterMovies = MovieController.shared.recommendedTheaterMoviesToDisplayToTheUser else {return}
            let theaterMovie = theaterMovies[indexPath.row]
            
            guard let index = MovieController.shared.moviesThatAreSmilar.index(where: { $0.title == theaterMovie.title }) else {return}
            
            let movie = MovieController.shared.moviesThatAreSmilar[index]
            destination.theaterMovie = theaterMovie
            destination.movie = movie
            
        }
        
    }
}
