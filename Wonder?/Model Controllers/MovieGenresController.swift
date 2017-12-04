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
    
    var genresList: [Genre] = [] {
        didSet {
            NotificationCenter.default.post(name: GenresController.genreWasUpatedNotifaction, object: nil)
        }
    }
    
    
    
    
    // MARK: - Fetch Genres
    func fetchGenres(completion: @escaping (([Genre]?) -> Void) = {_ in}) {
        
        let jsonFilePath = Bundle.main.path(forResource: "Genre", ofType: "json")
        var filedata: Data?
        
        guard let filePath = jsonFilePath else {return}
        filedata = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        
        
        guard let data = filedata else {print("Bad data"); return}
        
        
        let decoder = JSONDecoder()
        guard let genre = (try? decoder.decode(Genres.self, from: data)) else {print("Error decoding genres"); return}
        
        genresList = genre.genres
        
        
        
        
    }
    
    /// Toggle the status of a genre
    func toggleIsLikedStatusFor(genre: Genre, isLiked: Bool) {
        var oldGenre = genre
        oldGenre.isLiked = isLiked
        guard let index = genresList.index(of: genre) else {return}
        genresList.remove(at: index)
        genresList.insert(oldGenre, at: index)
    }
    
    func filterUnlikedAndLikedGenres() {
        likedGenres = genresList.filter( { $0.isLiked == true  } )
        unlikedGenres = genresList.filter({ $0.isLiked == false })
    }
    
}







