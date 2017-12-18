//
//  MovieTrailorController.swift
//  Wonder?
//
//  Created by Austin Betzer on 12/14/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation

class MovieTrailorController {
    static let shared = MovieTrailorController()
    
    // MARK: - Propertes
    var trailors: [MovieTrailers.MovieTrailor] = []
    
    //https://api.themoviedb.org/3/movie/1924/videos?api_key=c366b28fa7f90e98f633846b3704570c&language=en-US
    
    func fetchMovieTrailorWith(movie id: Int, completion: @escaping ([MovieTrailers.MovieTrailor]) -> Void) {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(id)/videos?api_key=c366b28fa7f90e98f633846b3704570c&language=en-US") else {NSLog("Bad trailor URL for movieID \(id)")
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            if let error = error {
                NSLog("Error with the data in function \(#function): \(error.localizedDescription)}")
                completion([])
                return
            }
            
            guard let data = data else {
                completion([])
                return
            }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                
                let results = try jsonDecoder.decode(MovieTrailers.self, from: data)
                self.trailors = results.results
                self.updateTrailorWith(trailors: self.trailors, and: id)
                completion(results.results)
            } catch let error {
                print(error.localizedDescription)
                completion([])
            }
            
            }.resume()
    }
    
    func updateTrailorWith(trailors: [MovieTrailers.MovieTrailor], and MovieId: Int) {
        
        var updatedTrailers = trailors
        
        for trailor in trailors {
            var newTrailor = trailor
            newTrailor.movieID = MovieId
            
            guard let index = trailors.index(where: { $0.id == newTrailor.id }) else {return}
            
            updatedTrailers.remove(at: index)
            updatedTrailers.insert(newTrailor, at: index)
        }
        
        self.trailors += updatedTrailers
        
    }
}














