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
    static let movieGenreWasUpatedNotifaction = Notification.Name("movieGenreWasUpdated")
    static let tvShowGenreWasUpdated = Notification.Name("tvShowGenreWasUpdated")
    
    var likedMovieGenres: [Genre] = []
    var unlikedMovieGenres: [Genre] = []
    
    var movieGenres: [Genre] = [] {
        didSet {
            NotificationCenter.default.post(name: GenresController.movieGenreWasUpatedNotifaction, object: nil)
        }
    }
    
    var tvShowGenres: [Genre] = [] {
        didSet {
            NotificationCenter.default.post(name: GenresController.tvShowGenreWasUpdated, object: nil)
        }
    }
    
    
    
    
    // MARK: - Fetch Genres
    func fetchMovieGenres(completion: @escaping (([Genre]?) -> Void) = {_ in}) {
        
        let jsonFilePath = Bundle.main.path(forResource: "Genre", ofType: "json")
        var filedata: Data?
        
        guard let filePath = jsonFilePath else {return}
        filedata = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        
        
        guard let data = filedata else {print("Error with Movie Genre Data in \(#file) and function: \(#function)"); return}
        
        
        let decoder = JSONDecoder()
        guard let movieGenresList = (try? decoder.decode(Genres.self, from: data)) else {print("Error decoding Movie Genres in function \(#function)"); return}
        
        movieGenres = movieGenresList.genres
    }
    
    func fetchTvShowGenres(completion: @escaping (([Genre]?) -> Void) = {_ in}) {
        let jsonFilePath = Bundle.main.path(forResource: "tvShowGenres", ofType: "json")
        var fileData: Data?
        
        guard let filePath = jsonFilePath else {return}
        fileData = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        
        guard let data = fileData else {print("Error with TV Show Genre Data in \(#file) and function: \(#function)"); return}
        
        let decoder = JSONDecoder()
        guard let tvShowGenreList = (try? decoder.decode(Genres.self, from: data)) else {print("Error decoding Tv Show Genres in function \(#function)"); return}
        
        tvShowGenres = tvShowGenreList.genres
        
    }
    
    /// Toggle the status of a genre
    func toggleIsLikedStatusFor(genre: Genre, isLiked: Bool) {
        var oldGenre = genre
        oldGenre.isLiked = isLiked
        guard let index = movieGenres.index(of: genre) else {return}
        movieGenres.remove(at: index)
        movieGenres.insert(oldGenre, at: index)
    }
    
    func filterUnlikedAndLikedGenres() {
        likedMovieGenres = movieGenres.filter( { $0.isLiked == true  } )
        unlikedMovieGenres = movieGenres.filter({ $0.isLiked == false })
    }
    
}







