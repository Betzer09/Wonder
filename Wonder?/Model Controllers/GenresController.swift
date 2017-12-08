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
        do {
            let movieGenresList = try decoder.decode(Genres.self, from: data)
            movieGenres = movieGenresList.genres
        } catch {
            NSLog("Error decoding Movie Genres in function \(#function): \(error)")
        }
    }
    
    func fetchImageForGenre(genres: [Genre]) {
        
        // We need to get a movies to fetch genres from
        // We need assign an images to every genrie that gets initalized when the app loads
        
        // For each genre in genres we need to fetch that id and assign it to that genre
        for genre in genres {
            
            
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
                
                MovieController.shared.fetchMoviesBasedOnGenresWith(ids: [genre.id], pageCount: 1, completion: { (movies) in
                    // Get the first movie that comes and check if we already have that movie
                    guard let movies = movies else {return}
                    let movieIndex = Int(arc4random_uniform(15))
                    var movie = movies[movieIndex]
                    
                    while self.genreMoviesThatHaveAlreadyBeenDisplayed.contains(movie) {
                        let newMovieIndex = Int(arc4random_uniform(15))
                        movie = movies[newMovieIndex]
                    }
                    
                    guard let path = movie.posterPath else {print("There is no image for \"\(movie.title)\" and genre: \(genre.name) in file\(#file) and \(#function)"); return}
                    MovieController.shared.fetchImageWith(endpoint: path, completion: { (image) in
                        guard let image = image, let dataOfImage = UIImagePNGRepresentation(image) else {print("Error saving the data of the image in file \(#file) and function \(#function)"); return}
                        self.updateGenreWithImage(data: dataOfImage, genre: genre)
                    })
                    
                    self.genreMoviesThatHaveAlreadyBeenDisplayed.append(movie)
                })
            })
        }
        
    }
    
    func updateGenreWithImage(data: Data, genre: Genre) {
        var oldGenre = genre
        oldGenre.genreImageData = data
        
        // Find the index
        guard let index = movieGenres.index(of: genre) else {print("There is no genre that matches the old genre in function: \(#function)"); return}
        movieGenres.remove(at: index)
        
        movieGenres.insert(oldGenre, at: index)
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
        MovieController.shared.fetchMoviesBasedOnGenresWith(ids: [id], pageCount: 1) { (movies) in
            var movieCounter = Int(arc4random_uniform(10))
            
            // Get the first movie that comes back and grab the poster path
            guard let movies = movies else {print("There are no movies to return an image form in file \(#file) and function\(#function)"); return}
            var movie = movies[movieCounter]
            
            // Check for duplicate movies
            if self.genreMoviesThatHaveAlreadyBeenDisplayed.contains(movie) {
                // Increment the number from the very start that way we can reassign movie
                movieCounter = Int(arc4random_uniform(10))
                
                // We want to get a different movie
                movie = movies[movieCounter]
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








