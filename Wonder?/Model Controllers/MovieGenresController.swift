//
//  MovieGenresController.swift
//  Wonder?
//
//  Created by Austin Betzer on 11/20/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation

class GenresController {
    
    // MARK: - Properties
    static let shared = GenresController()
    static let genreWasUpatedNotifaction = Notification.Name("genreWasUpdated")
    
    let baseURL = URL(string: "https://api.themoviedb.org/3/genre/movie/list")
    var likedGenres: [Genre] = []
    var unlikedGenres: [Genre] = []
    
    var genres: [Genre] = [] {
        didSet {
            NotificationCenter.default.post(name: GenresController.genreWasUpatedNotifaction, object: nil)
        }
    }
    
    
    
    
    // MARK: - Fetch Genres
    func fetchGenres(completion: @escaping ([Genre]?) -> Void) {
        
        guard let unwrappedURL = baseURL else { NSLog("Bad URL \(#file)"); return}
        
        var urlComponents = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: true)
        let paramters = ["api_key": "c366b28fa7f90e98f633846b3704570c"]
        urlComponents?.queryItems = paramters.flatMap { URLQueryItem(name: $0.key, value: $0.value)}
        
        guard let url = urlComponents?.url else { NSLog("Bad URL Components"); return}
        
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching Genres \(error.localizedDescription) in file\(#file)")
                completion([])
                return
            }
            
            // Do something with the data
            guard let data = data else { NSLog("There was bad data! \(#file)"); completion([]); return}

            // Decode the data
            guard let genre = (try? JSONDecoder().decode(Genres.self, from: data)) else {return}

            self.genres = genre.genres
            completion(genre.genres)
            
        }.resume()
        
    }
    
    /// Toggle the status of a genre
    func toggleIsLikedStatusFor(genre: Genre, isLiked: Bool) {
        var oldGenre = genre
        oldGenre.isLiked = isLiked
        guard let index = genres.index(of: genre) else {return}
        genres.remove(at: index)
        genres.insert(oldGenre, at: index)
    }
    
    func filterUnlikedAndLikedGenres() {
        likedGenres = genres.filter( { $0.isLiked == true  } )
        unlikedGenres = genres.filter({ $0.isLiked == false })
    }
    
}







