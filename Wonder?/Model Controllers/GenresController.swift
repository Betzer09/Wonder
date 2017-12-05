//
//  MovieGenresController.swift
//  Wonder?
//
//  Created by Austin Betzer on 11/20/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import  UIKit

class GenresController {
    
    static let shared = GenresController()
    
    // MARK: - Notification Names
    static let movieGenreWasUpatedNotifaction = Notification.Name("movieGenreWasUpdated")
    static let tvShowGenreWasUpdated = Notification.Name("tvShowGenreWasUpdated")
    static let likedMovieGenresArrayWasUpdated = Notification.Name("likedGenresWereUpdated")
    static let unlikedMovieGenresArrayWasUpdated = Notification.Name("unlikedGenresWereUpdated")
    
    // MARK: - Properties
    var genreMoviesThatHaveAlreadyBeenDisplayed: [Movie] = []
    var movieCounter = 0
    var likedMovieGenres: [Genre] = [] {
        didSet {
            NotificationCenter.default.post(name: GenresController.likedMovieGenresArrayWasUpdated, object: nil)
        }
    }
    var unlikedMovieGenres: [Genre] = [] {
        didSet {
            NotificationCenter.default.post(name: GenresController.unlikedMovieGenresArrayWasUpdated, object: nil)
        }
    }
    
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
    

    // MARK: - Fetch Functions
    /// Fetches the Movie Genres from the device
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
    
    /// Fetches the Tv Show Genres from the device
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
    
    /// Fetches a genre image
    func fetchImageForGenre(with id: Int, completion: @escaping (UIImage?) -> Void) {
        // Reset this number everytime this gets called that way we don't end up outside the bounds of the movies array
        movieCounter = 0
        
        MovieController.shared.fetchMoviesBasedOnGenresWith(ids: [id], pageCount: 1) { (movies) in
            // Get the first movie that comes back and grab the poster path
            guard let movies = movies else {print("There are no movies to return an image form in file \(#file) and function\(#function)"); return}
            var movie = movies[self.movieCounter]
            
            // Check for duplicate movies
            if self.genreMoviesThatHaveAlreadyBeenDisplayed.contains(movie) {
                // Increment the number from the very start that way we can reassign movie
                self.movieCounter = Int(arc4random_uniform(10))
                
                // We want to get a different movie
                movie = movies[self.movieCounter]
            } else {
                // We can use the movie we have
                self.genreMoviesThatHaveAlreadyBeenDisplayed.append(movie)
            }
            
            guard let path = movie.posterPath else {print("Error fetching the posterPath of the movie in file: \(#file) and function: \(#function)");  return}
            // Once you have the poster path fetch the image and set it as the image
            
            MovieController.shared.fetchImageWith(endpoint: path, completion: { (image) in
                guard let image = image else {print("Error fetching genre image in file: \(#file) and function: \(#function)"); completion(nil); return}
                completion(image)
            })
  
        }
        
    }
    
    // MARK: - Functions
    /// Toggle the status of a genre
    func toggleIsLikedStatusFor(genre: Genre, isLiked: Bool) {
        var oldGenre = genre
        oldGenre.isLiked = isLiked
        guard let index = movieGenres.index(of: genre) else {return}
        movieGenres.remove(at: index)
        movieGenres.insert(oldGenre, at: index)
        sendGenreToAppropriateArray(genre: oldGenre, isLiked: isLiked)
    }
    
   private func sendGenreToAppropriateArray(genre: Genre, isLiked: Bool) {
        if isLiked {
            likedMovieGenres.append(genre)
        } else {
            unlikedMovieGenres.append(genre)
        }
    }
    
}








