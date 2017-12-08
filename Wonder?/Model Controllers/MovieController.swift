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
    var nowPlayingMovies: [Movie] = []
    var moviesThatAreSimilar: [Movie] = []
    var recommendedMovieTheaterMoviesToDisplayToTheUser: [TheatreMovies.TheaterMovie]? = []
    var timer = Timer()
    
    // MARK: - Fetch Functions
    /// Movie DB recommeded Movies
    func fetchRecommendedMovieWith(id: Int, completion: @escaping (Movie?) -> Void) {
        
        let recommendMoviesURL = URL(string: "https://api.themoviedb.org/3/movie/\(id)/recommendations")
        guard let unwrappedURL = recommendMoviesURL else {NSLog("Bad URL: \(#file)"); return }
        
        var urlComponents = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: true)
        let parameters = ["api_key": "c366b28fa7f90e98f633846b3704570c", "language": "en-US", "page": "1"]
        urlComponents?.queryItems = parameters.flatMap {URLQueryItem(name: $0.key, value: $0.value)}
        
        guard let url = urlComponents?.url else {NSLog("Bad URL Components \(#file)"); return}
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching recommended Movies \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {NSLog("Error with the data \(#file)"); return}
            
            guard let movies = (try? JSONDecoder().decode(Movies.self, from: data)) else {
                NSLog("Error decoding recommend movie in \(#file) and function: \(#function)")
                print("\(id)")
                return
            }
            
            guard let movie = movies.results.first else {NSLog("Error there is no recommended movie in file: \(#file) and function \(#function)"); return}
            self.recommendedMovies.append(movie)
            completion(movies.results.first)
            
            }.resume()
        
    }
    
    //https://api.themoviedb.org/3/discover/movie?api_key=c366b28fa7f90e98f633846b3704570c&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_genres=28
    /// MovieDB Discover
    func fetchMoviesBasedOnGenresWith(ids: [Int], pageCount: Int, completion: @escaping ([Movie]?) -> Void) {
        
        let discoverMoviesBaseURL = URL(string: "https://api.themoviedb.org/3/discover/movie")
        
        guard let unwrappedURL = discoverMoviesBaseURL else {NSLog("Bad Discover URL \(#file)"); return}
        
        var urlComponents = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: true)
        var stringOfIDs = ""
        
        for id in ids {
            stringOfIDs.append("\(id)")
        }
        
        let parameters = ["api_key": "c366b28fa7f90e98f633846b3704570c",
                          "language": "en-US",
                          "page": "\(pageCount)",
            "sort_by": "popularity.desc",
            "include_adult": "false",
            "include_video": "false",
            "with_genres": stringOfIDs
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
            
            do{
                let movies = try JSONDecoder().decode(Movies.self, from: data)
                
                self.discoveredMoviesBasedOnGenres = movies.results
                completion(movies.results)
            } catch let error {
                print("Error initalzing discovered movies in function \(#file) and function: \(#function) becuase of error: \(error.localizedDescription)")
            }
            }.resume()
        
        
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
    
    //https://api.themoviedb.org/3/movie/562/similar?api_key=c366b28fa7f90e98f633846b3704570c&language=en-US&page=1
   private func fetchMoviesThatAreSimilarWith(movie id: Int, completion: @escaping ([Movie]?) -> Void) {
        let baseURL = URL(string: "https://api.themoviedb.org/3/movie/")!.appendingPathComponent("\(id)")
        
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        let parameters = ["api_key": "c366b28fa7f90e98f633846b3704570c", "language": "en-US" ]
        
        urlComponents?.queryItems = parameters.flatMap( { URLQueryItem(name: $0.key , value: $0.value)})
        
        guard let url = urlComponents?.url else {NSLog("Bad url components in function: \(#function)"); return}
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            if let error = error {
                print("Error fetching movies that are \"Similar\" to the movie from the MovieDB in file: \(#file) and function: \(#function) because of error: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = data else {print("Error with \"Similar Movie\"  MovieDB data in file \(#file) and function:\(#function) "); return}
            
            
            do {
                let movies = try JSONDecoder().decode(Movies.self, from: data)
                self.moviesThatAreSimilar += movies.results
                completion(movies.results)
            } catch let error {
                print("Error initalzing \"Similar\" movies in function \(#file) and function: \(#function) becuase of error: \(error.localizedDescription)")
            }
            
            
        }.resume()
        
        
    }
    
    //https://api.themoviedb.org/3/movie/now_playing?api_key=c366b28fa7f90e98f633846b3704570c&language=en-US&page=3
    /// This returns movies that are currently playing according to the movieDB
    private func fetchMoviesThatAreNowPlaying(page: Int, completion: @escaping ([Movie]?) -> Void) {
        let baseURL = URL(string: "https://api.themoviedb.org/3/movie/now_playing")
        
        guard let unwrappedURL = baseURL else {NSLog("Bad \"Now Playing\" URL \(#file) and function \(#function)"); return}
        
        var urlComponents = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: true)
        
        let parameters = ["api_key": "c366b28fa7f90e98f633846b3704570c",
                          "page": "\(page)",
            "language": "en-US" ]
        
        urlComponents?.queryItems = parameters.flatMap( { URLQueryItem(name: $0.key , value: $0.value)})
        
        guard let url = urlComponents?.url else {NSLog("Bad url components in function: \(#function)"); return}
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            if let error = error {
                print("Error fetching movies that are Now Playing from the MovieDB in file: \(#file) and function: \(#function) because of error: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = data else {print("Error with Now Playing MovieDB data in file \(#file) and function:\(#function) "); return}
            
            
            do {
                let movies = try JSONDecoder().decode(Movies.self, from: data)
                self.nowPlayingMovies = movies.results
                completion(movies.results)
            } catch let error {
                print("Error initalzing Now Playing movies in function \(#file) and function: \(#function) becuase of error: \(error.localizedDescription)")
            }
            
        }.resume()
        
        
    }
    
    
    func returnRecommendMovies() -> [TheatreMovies.TheaterMovie] {
        // If the answer is true they want to go the the movie theaters
        let answer = QuestionController.shared.doesTheUserWantToGoOut()
        var value: [TheatreMovies.TheaterMovie] = []
        // Fetch movies in theaters
        if answer {
            // Fetch theaterMovies that are in theaters if this fails just fetch movies that are in theaters using the movieDB
            TheatreController.shared.fetchTheaterMovies(completion: { (theaterMovies) in
                guard let theaterMovies = theaterMovies else {return}
                if theaterMovies.isEmpty {
                    // Fetch movies that are now playing useing the movieDB
                    
                    MovieController.shared.fetchMoviesThatAreNowPlaying(page: 1, completion: { (movies) in
                        
                        
                        
                    })
                    
                    
                } else {
                    // This means we still have API calls and got movies from the TheaterShowtime API
                    // Fetch movies that are currently in theaters using the movieDB
                    MovieController.shared.fetchMoviesThatAreNowPlaying(page: 1, completion: { (movies) in
                        guard let movies = movies else {print("There are no movies that are playing... in file \(#file) and function: \(#function)"); return}
                        // Combine both of those arrays and get what's similar
                        let theaterMovieNames = theaterMovies.map({ $0.title })
                        let movieDBNames = movies.map({$0.title})
                        
                        let similarMovies = self.checkForSimilarTitlesWith(theaterMovieNames: theaterMovieNames, moviesDBNames: movieDBNames)
                        // Now go back and initalize the similar movies
                        let moviesThatAreSimilar = self.findMoviesThatAreSimilarWith(similarMovies, movies: movies)
                        // Filter out all the movies that don't match their liked genres
                        let moviesThatMatchTheLikedGenres = self.findSimilarMovies(moviesThatAreSimilar: moviesThatAreSimilar)
                        self.recommendedMovieTheaterMoviesToDisplayToTheUser = self.turnMoviesIntoATheaterMoviesWith(movies: moviesThatMatchTheLikedGenres)
                        value = self.turnMoviesIntoATheaterMoviesWith(movies: moviesThatMatchTheLikedGenres)
                    })

                    
                }
                
            })
        } else {
            // Fetch the top rated and popular Movies
            // Filter out all the movies that don't match their liked genres
            // Take the "liked Movies" and grab their ID
            // Use the array of IDS and Start from the top and fetch reccomed movies based on those id
            // If they don't like a movie that's reccomend filter out all simlar movies
        }
        
        return value
    }
    
    // MARK: - Functions
    
    func turnMoviesIntoATheaterMoviesWith(movies: [Movie]) -> [TheatreMovies.TheaterMovie]{
        
        let theaterMovies = TheatreController.shared.theaterMovies
        var theaterMoviesToReturn: [TheatreMovies.TheaterMovie] = []
        
        for movie in movies {
            
            for theaterMovie in theaterMovies {
                
                if movie.title == theaterMovie.title {
                    theaterMoviesToReturn.append(theaterMovie)
                }
                
            }
        }
        
        return theaterMoviesToReturn
        
    }
    
   private func findSimilarMovies(moviesThatAreSimilar: [Movie]) -> [Movie] {
        let likedGenreIDs = GenresController.shared.likedMovieGenres.map({ $0.id }).sorted()
        var similarIDS = 0
        var moviesToReturn: [Movie] = []
        
        // We need to compare each liked id to each id in a movie
        // If there are two ID's that are similar that is a match we just append that movie
        
        for id in likedGenreIDs {
            
            for movie in moviesThatAreSimilar {
                
                if movie.genreIDS.contains(id) {
                    similarIDS += 1
                    // Append that movie
                    if similarIDS >= 2 {
                        moviesToReturn.append(movie)
                        continue
                    }
                }
            }
        }
        
        return moviesThatAreSimilar
    }
    
    /// This finds movies that are similar and returns and array of movies
   private func findMoviesThatAreSimilarWith(_ similarMovies: [String], movies: [Movie]) -> [Movie] {
        var moviesThatAreSimilar: [Movie] = []
        for movieName in similarMovies {
            
            for movie in movies {
                
                if movieName == movie.title {
                    moviesThatAreSimilar.append(movie)
                }
            }
        }
        
        return moviesThatAreSimilar
    }
    
    /// This checks for similar titles and returns an array of string titles
   private func checkForSimilarTitlesWith(theaterMovieNames: [String], moviesDBNames: [String]) -> [String] {
        
        var similarMovies: [String] = []
        
        for movieName in moviesDBNames {
            
            for theaterName in theaterMovieNames {
                // Check for similar names
                if theaterName.lowercased() == movieName.lowercased() {
                    similarMovies.append(theaterName)
                }
                
            }
        }
        
        return similarMovies
    }
    
    
}
