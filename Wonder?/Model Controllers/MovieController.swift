//
//  MovieController.swift
//  Wonder?
//
//  Created by Austin Betzer on 11/21/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class MovieController {
    
    // MARK: - Properties
    static let shared = MovieController()
    var recommendedMovies: [Movie] = []
    var discoveredMoviesBasedOnGenres: [Movie] = []
    
    // MARK: - Methods
    func fetchRecommnedMoviesWith(id: Int, completion: @escaping ([Movie]?) -> Void) {
        
        let recommendMoviesURL = URL(string: "https://api.themoviedb.org/3/movie/\(id)/recommendations")
        // This just adds the id may not be the most conventienal way to do it
        guard let unwrappedURL = recommendMoviesURL else {NSLog("Bad URL: \(#file)"); return }
        
        var urlComponents = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: true)
        let parameters = ["api_key": "c366b28fa7f90e98f633846b3704570c", "language": "en-US", "page": "1"]
        urlComponents?.queryItems = parameters.flatMap {URLQueryItem(name: $0.key, value: $0.value)}
        
        guard let url = urlComponents?.url else {NSLog("Bad URL Components \(#file)"); return}
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching recommended Movies \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = data else {NSLog("Error with the data \(#file)"); return}
            
            guard let movies = (try? JSONDecoder().decode(Movies.self, from: data)) else {
                NSLog("No Recommened Movie \(#file)")
                return
            }
            
            self.recommendedMovies = movies.results
            completion(movies.results)
            
        }.resume()
        
    }
    
    //https://api.themoviedb.org/3/discover/movie?api_key=c366b28fa7f90e98f633846b3704570c&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_genres=28
    func fetchMoviesBasedOnGenresWith(ids: [Int], pageCount: Int, completion: @escaping ([Movie]?) -> Void) {
        
        let discoverMoviesBaseURL = URL(string: "https://api.themoviedb.org/3/discover/movie")
        
        guard let unwrappedURL = discoverMoviesBaseURL else {NSLog("Bad Discover URL \(#file)"); return}
        
        var urlComponents = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: true)
        let parameters = ["api_key": "c366b28fa7f90e98f633846b3704570c",
                          "language": "en-US",
                          "page": "1",
                          "sorted_by": "popularity.desc",
                          "include_adult": "false",
                          "include_video": "false",
                          "page": "\(pageCount)",
                          "with_genres":  "\(ids.flatMap({ $0 }))|"
                          ]
        
        urlComponents?.queryItems = parameters.flatMap( {URLQueryItem(name: $0.key, value: $0.value)})
        guard let url = urlComponents?.url else {NSLog("Bad url components \(#function)"); return}
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching Moves based on Genres: \(error.localizedDescription). In function: \(#function)")
                completion([])
                return
            }
            
            guard let data = data else {NSLog("Error with the data in function \(#function)"); return}
            
            guard let movies = (try? JSONDecoder().decode(Movies.self, from: data)) else {
                NSLog("Error Decoding the movies in function: \(#function)")
                completion([])
                return
            }
            
            self.discoveredMoviesBasedOnGenres = movies.results
            completion(movies.results)
            
        }
        
    }
    
    func fetchImageWith(endpoint: String, completion: @escaping (UIImage?) -> Void) {
        let imageURL = URL(string: "https://image.tmdb.org/t/p/w500/")!
        let url = imageURL.appendingPathComponent(endpoint)
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            // Check for an error
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
                return
            }
            
            // Check for data
            guard let data = data else {
                print("There was bad data")
                completion(nil)
                return
            }
            
            // If there is data turn it into an image
            let image = UIImage(data: data)
            
            // completion with an image
            completion(image)
            }.resume()
    }
    
}



















