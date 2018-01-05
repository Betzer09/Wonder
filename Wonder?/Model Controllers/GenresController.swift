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
    
    func fetchImageForGenre(genres: [Genre], completion: @escaping (_ isComplete: Bool) -> Void) {
        
        // We need to get a movies to fetch genres from
        // We need assign an images to every genrie that gets initalized when the app loads
        // For each genre in genres we need to fetch that id and assign it to that genre
        let downloadGroup = DispatchGroup()
        for genre in genres {
            downloadGroup.enter()
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
                MovieController.shared.fetchMoviesBasedOnGenresWith(ids: [genre.id], pageCount: 1, completion: { (movies) in
                    // Get the first movie that comes and check if we already have that movie
                    if movies.isEmpty {return}
                    let movieIndex = Int(arc4random_uniform(UInt32(movies.count - 1)))
                    var movie = movies[movieIndex]
                    
                    // Make sure there are no duplicates
                    while self.genreMoviesThatHaveAlreadyBeenDisplayed.contains(movie) {
                        let newMovieIndex = Int(arc4random_uniform(UInt32(movies.count - 1)))
                        movie = movies[newMovieIndex]
                    }
                    
                    guard let path = movie.posterPath else {
                        print("There is no image posterpath for the fetch: for \"\(movie.title)\" and genre: \"\(genre.name)\" in file\(#file) and \(#function)")
                        guard let data = UIImageJPEGRepresentation(#imageLiteral(resourceName: "noImageView"), 1.0) else {return}
                        genre.genreImageData = data
                        downloadGroup.leave()
                        return
                    }
                    GenresController.shared.fetchImageWith(endpoint: path, genre: genre, completion: { (isComplete) in
                        downloadGroup.leave()
                    })
                    
                    self.genreMoviesThatHaveAlreadyBeenDisplayed.append(movie)
                })
            })
        }
        
        downloadGroup.notify(queue: DispatchQueue.main) {
            completion(true)
        }
        
    }
    
    /// Fetches the images from the movie DB
    func fetchImageWith(endpoint: String, genre: Genre, completion: @escaping (_ isComplete: Bool) -> Void = { _ in }) {
        let imageURL = URL(string: "https://image.tmdb.org/t/p/w342/")!
        let url = imageURL.appendingPathComponent(endpoint)
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            // Check for an error
            if let error = error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            
            // Check for data
            guard let data = data else {
                print("There was bad data")
                completion(false)
                return
            }
            
            // If there is data turn it into an image
            guard let image = UIImage(data: data), let imageData = UIImageJPEGRepresentation(image, 1.0) else {return}
            genre.genreImageData = imageData
            completion(true)
            
            }.resume()
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
