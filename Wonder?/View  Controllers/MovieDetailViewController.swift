//
//  MovieDetailViewController.swift
//  Wonder?
//
//  Created by Austin Betzer on 12/14/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var trailorWebView: UIWebView!
    
    
    // MARK: - Properties
    var movie: Movie?
    var theaterMovie: TheatreMovies.TheaterMovie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let movie = movie else {return}
        MovieTrailorController.shared.fetchMovieTrailorWith(movie: movie.id, completion: { (trailors) in
            
            //            if trailors.count > 0 {
            self.findTrailorToFetch()
            //            }
        })
    }
    
    func findTrailorToFetch()  {
        // Get the index of the trailor
        guard let index = MovieTrailorController.shared.trailors.index(where: { $0.movieID == movie?.id }) else {return}
        let trailor = MovieTrailorController.shared.trailors[index]
        
        // Check if we get the right trailor
        let doesItMatch = checkIfTheTrailerMatchesWith(trailor: trailor, indexOfTrailor: index)
        
        if !doesItMatch {
            MovieTrailorController.shared.trailors.remove(at: index)
            self.findTrailorToFetch()
        }
        
    }
    
    
    
    func checkIfTheTrailerMatchesWith(trailor: MovieTrailers.MovieTrailor, indexOfTrailor: Int) -> Bool {
        
        let charactors = trailor.name.lowercased().map({ $0 })
        let answer = "Official Trailer"
        let answerCharactors = answer.lowercased().map({ $0 })
        var count = 0
        
        for i in 0...answerCharactors.count {
            
            if i >= answerCharactors.count {
                NSLog("Out of range: in function \(#function)")
                break
            }
            
            if count >= 12 {
                
                if Double(count) / Double(answerCharactors.count) > 0.7 {
                    fetch(trailor: trailor)
                    return true
                } else {
                    self.findTrailorToFetch()
                }
                
            }
            
            if answerCharactors[i] == charactors[i] {
                count += 1
            } else {
                break
            }
            
        }
        
        return false
    }
    
    func fetch(trailor: MovieTrailers.MovieTrailor) {
        guard let url = URL(string: "https://www.youtube.com/embed/\(trailor.key)") else {
            NSLog("Bad trailor URL for movie with id: \" \(trailor.movieID!) \" ")
            return
        }
        DispatchQueue.main.async {
            self.trailorWebView.loadRequest(URLRequest(url: url))
        }
    }
    
}
