//
//  MovieController.swift
//  Wonder?
//
//  Created by Austin Betzer on 11/21/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation

class MovieController {
    
    static let shared = MovieController()
    
    var baseURL = URL(string: "https://api.themoviedb.org/3/movie/")
    var recommendedMovies: [Movie] = []
    
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
    
}
