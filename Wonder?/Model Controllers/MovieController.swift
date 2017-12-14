//
//  MovieController.swift
//  Wonder?
//
//  Created by Austin Betzer on 11/21/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class MovieController {
    // MARK: - Notifcations
    static let similarMoviesToDisplayToTheUserWasUpdated = Notification.Name("similarMoviesToDisplayToTheUserWasUpdated")
    
    // MARK: - Properties
    static let shared = MovieController()
    var recommendedMovies: [Movie] = []
    var discoveredMoviesBasedOnGenres: [Movie] = []
    var nowPlayingMovies: [Movie] = []
    var recommendedTheaterMoviesToDisplayToTheUser: [TheatreMovies.TheaterMovie]? = []
    
    /// An array full of similar movies that were fetched from the MovieDB. This will be modified at the end and be displayed to the user in the end as the final result.
    var similarRecommendedMovies: [Movie] = []
    
    /// This is an array full of similar movies that should be displayed to the user to swipe through
    var similarMoviesToDisplayToTheUser: [Movie] = [] {
        didSet {
            NotificationCenter.default.post(name: MovieController.similarMoviesToDisplayToTheUserWasUpdated, object: nil)
        }
    }
    
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
    private func fetchMoviesThatAreSimilarWith(movie id: Int, completion: @escaping ([Movie]) -> Void) {
        
        let customURL = "https://api.themoviedb.org/3/movie/\(id)/similar"
        guard let baseURL = URL(string: customURL) else { completion([]); NSLog("Bad \"Similar Movie\" URL in function: \(#function)"); return}
        
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        let parameters = ["api_key": "c366b28fa7f90e98f633846b3704570c", "language": "en-US" ]
        
        urlComponents?.queryItems = parameters.flatMap( { URLQueryItem(name: $0.key , value: $0.value)})
        
        guard let url = urlComponents?.url else { completion([]); NSLog("Bad url components in function: \(#function)"); return}
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            if let error = error {
                print("Error fetching movies that are \"Similar\" to the movie from the MovieDB in file: \(#file) and function: \(#function) because of error: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = data else { completion([]); print("Error with \"Similar Movie\"  MovieDB data in file \(#file) and function:\(#function) "); return}
            
            
            do {
                let movies = try JSONDecoder().decode(Movies.self, from: data)
                NSLog(" \(movies.results.count) and the url was \(url)")
                guard let movie = movies.results.first, let path = movie.posterPath else {
                    completion([]);
                    return
                }
                
                self.fetchImageWith(endpoint: path, completion: { (image) in
                    guard let image = image, let data = UIImagePNGRepresentation(image) else {NSLog("Error convert \"\(movie.title)'s\" image data in function \(#function)"); return}
                    let updatedMovie = self.updateImageDataAndTitleFor(movie: movie, with: data, title: nil)
                    
                    if self.similarMoviesToDisplayToTheUser.contains(movie) {
                        guard let index = self.similarMoviesToDisplayToTheUser.index(of: movie) else {return}
                        self.similarMoviesToDisplayToTheUser.remove(at: index)
                        
                        self.similarMoviesToDisplayToTheUser.insert(updatedMovie, at: index)
                    }
                })
                
                self.similarMoviesToDisplayToTheUser.append(movie)
                completion(movies.results)
            } catch let error {
                NSLog("Error initalzing \"Similar\" movie with URL \(url) in function \(#file) and function: \(#function) becuase of error: \(error.localizedDescription)")
                completion([]);
            }
            
            }.resume()
    
    }
    
    //https://api.themoviedb.org/3/movie/now_playing?api_key=c366b28fa7f90e98f633846b3704570c&language=en-US&page=3
    /// This returns movies that are currently playing according to the movieDB
    private func fetchMoviesThatAreNowPlaying(page: Int, completion: @escaping ([Movie]?) -> Void) {
        let baseURL = URL(string: "https://api.themoviedb.org/3/movie/now_playing")
        
        guard let unwrappedURL = baseURL else {NSLog("Bad \"Now Playing\" URL \(#file) and function \(#function)");
            completion([])
            return
        }
        
        var urlComponents = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: true)
        
        let parameters = ["api_key": "c366b28fa7f90e98f633846b3704570c",
                          "page": "\(page)",
            "language": "en-US" ]
        
        urlComponents?.queryItems = parameters.flatMap( { URLQueryItem(name: $0.key , value: $0.value)})
        
        guard let url = urlComponents?.url else {NSLog("Bad url components in function: \(#function)")
            completion([])
            return
            
        }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            if let error = error {
                print("Error fetching movies that are Now Playing from the MovieDB in file: \(#file) and function: \(#function) because of error: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = data else {print("Error with Now Playing MovieDB data in file \(#file) and function:\(#function) ")
                completion([])
                return
            }
            
            
            do {
                let movies = try JSONDecoder().decode(Movies.self, from: data)
                self.nowPlayingMovies = movies.results
                completion(movies.results)
            } catch let error {
                print("Error initalzing Now Playing movies in function \(#file) and function: \(#function) becuase of error: \(error.localizedDescription)")
                completion([])
            }
            
            }.resume()
        
        
    }
    
    
    func fetchRecommendedMovies(completion: @escaping (_ isComplete: Bool) -> Void) {
        // If the answer is true they want to go the the movie theaters
        let answer = QuestionController.shared.doesTheUserWantToGoOut()
        print(answer)
        // Fetch movies in theaters
        if answer {
            // Fetch theaterMovies that are in theaters if this fails just fetch movies that are in theaters using the movieDB
            TheatreController.shared.fetchTheaterMovies(completion: { (theaterMovies) in
                guard let theaterMovies = theaterMovies else {return}
                if theaterMovies.isEmpty {
                    // Fetch movies that are now playing useing the movieDB
                    
                    MovieController.shared.fetchMoviesThatAreNowPlaying(page: 1, completion: { (movies) in
                        print("Fix Me")
                        completion(true)
                        
                    })
                    
                    
                } else {
                    // This means we still have API calls and got movies from the TheaterShowtime API
                    // Fetch movies that are currently in theaters using the movieDB
                    MovieController.shared.fetchMoviesThatAreNowPlaying(page: 1, completion: { (movies) in
                        guard let movies = movies else {print("There are no movies that are playing... in file \(#file) and function: \(#function)"); return}
                        // Combine both of those arrays and get what's similar
                        let theaterMovieNames = theaterMovies.map({ $0.title })
                        let movieDBNames = movies.map({$0.title})
                        
                        let similarMovieTitles = self.checkForSimilarTitlesWith(theaterMovieNames: theaterMovieNames, moviesDBNames: movieDBNames)
                        // Now go back and initalize the similar movies
                        let initalziedMoviesThatAreSmilar = self.initalizeTheMoviesThatAreSimilarWith(similarMovieTitles, movies: movies)
                        // Filter out all the movies that don't match their liked genres
                        let moviesThatMatchTheirLikedGenres = self.filterOutMoviesThatDontMatchTheirLikedGenresWith(moviesThatAreSimilar: initalziedMoviesThatAreSmilar)
                        
                        // This just goes through and updates the current movies with their updated properties
                        self.fetchMoviesThatAreSimilarWith(moviesThatMatchTheirLikedGenres: moviesThatMatchTheirLikedGenres, completion: { (isComplete) in
                            if isComplete {
                                completion(true)
                            }
                        })
                        
                    })
                    
                }
                
            })
        } else {
            // Fetch the top rated and popular Movies
            // Filter out all the movies that don't match their liked genres
            // Take the "liked Movies" and grab their ID
            // Use the array of IDS and Start from the top and fetch reccomed movies based on those id
            // If they don't like a movie that's similar filter out the recommended movie
        }
    }
    
    var groupCount = 0 {
        didSet {
            print("Group count: \(groupCount)")
        }
    }
    
    // MARK: - Functions
    
    /// Fetches Movies that are similar using the movie ID and returns an array of Movies as well as assigns the similar movie to it's corrisponding recommended movie
    func fetchMoviesThatAreSimilarWith(moviesThatMatchTheirLikedGenres: [Movie], completion: @escaping (_ isComplete: Bool) -> Void) {
        
        var moviesThatMatch = moviesThatMatchTheirLikedGenres
        let fetchSimilarMoviesGroup = DispatchGroup()
        
        for movie in moviesThatMatchTheirLikedGenres {
            fetchSimilarMoviesGroup.enter()
            self.groupCount += 1
            print("Group entered")
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
                    self.fetchMoviesThatAreSimilarWith(movie: movie.id, completion: { (movies) in
                        
                        // Get the image data of each card too
                        print(movies.count)
                        if movies.count == 0 {
                            guard let indexOfMovie = moviesThatMatch.index(of: movie) else {
                                fetchSimilarMoviesGroup.leave()
                                self.groupCount -= 1
                                return
                            }
                            moviesThatMatch.remove(at: indexOfMovie)
                            fetchSimilarMoviesGroup.leave()
                            self.groupCount -= 1
                            return
                        } else {
                            
                            guard let endpoint = movies.first?.posterPath else {
                                print("Error there is no posterPath for the similar movie in function \(#function)")
                                fetchSimilarMoviesGroup.leave()
                                self.groupCount -= 1
                                return
                            }
                            
                            self.fetchImageWith(endpoint: endpoint, completion: { (image) in
                                guard let image = image, let data = UIImagePNGRepresentation(image), let title = movies.first?.title else {
                                    NSLog("No image. Location: \(#function)")
                                    fetchSimilarMoviesGroup.leave()
                                    self.groupCount -= 1
                                    return
                                }
                                
                                if moviesThatMatch.contains(movie) {
                                    let newMovie = self.updateImageDataAndTitleFor(movie: movie, with: data, title: title)
                                    guard let movieIndex = moviesThatMatch.index(of: movie) else {
                                        print("Error updating \"Similar Movie Property\" in function \(#function)")
                                        fetchSimilarMoviesGroup.leave()
                                        self.groupCount -= 1
                                        return
                                    }
                                    moviesThatMatch.remove(at: movieIndex)
                                    moviesThatMatch.insert(newMovie, at: movieIndex)
                                    fetchSimilarMoviesGroup.leave()
                                    self.groupCount -= 1
                                } else {
                                    fetchSimilarMoviesGroup.leave()
                                    self.groupCount -= 1
                                }
                            })
                        }
                    })
                })
            }
        }
        
        fetchSimilarMoviesGroup.notify(queue: DispatchQueue.main) {
            self.similarRecommendedMovies = moviesThatMatch
            completion(true)
        }
    }
    
    /// Filters out recommended movies that the user won't like based on similar movies they don't like. This will be used at the very end before we display them to the user
    func filterOutSimilarMoviesBasedOnSimilarMovieStatus() {
        
        var similarMovies = similarRecommendedMovies
        
        // if the movie is unliked remove it
        for movie in similarMovies {
            guard let isliked = movie.isLiked else {NSLog("Error \(#function)"); return}
            if !isliked {
                // We need to take out the corrisponding recommended movie
                guard let indexOfSimilerMovie = similarMovies.index(of: movie) else {NSLog("Error there is no similar movie that matches in function \(#function)"); return}
                similarMovies.remove(at: indexOfSimilerMovie)
            }
        }
        
        let theaterMovies = turnMoviesIntoATheaterMoviesWith(movies: similarMovies)
        self.recommendedTheaterMoviesToDisplayToTheUser = theaterMovies
    }
    
    func updateImageDataAndTitleFor(movie: Movie, with data: Data, title: String?) -> Movie {
        var oldMovie = movie
        oldMovie.imageData = data
        oldMovie.isSimilarTo = title
        
        return oldMovie
    }
    
    func toggleSimilarMoviesStatisFor(movie: Movie, with isliked: Bool) {
        var oldMovie = movie
        oldMovie.isLiked = isliked
        
        guard let indexOfMovie = similarRecommendedMovies.index(of: movie) else {NSLog("Error there is no movie that matches \(movie.title) in function: \(#function)") ;return}
        similarRecommendedMovies.remove(at: indexOfMovie)
        
        similarRecommendedMovies.insert(oldMovie, at: indexOfMovie)
    }
    
    /// This gets all of the MovieDB and converts thems to TheaterMovies 
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
    
    /// Filters out any movies that don't match their liked genres. Anything that is above 75% similar to their geners will be returned.
    private func filterOutMoviesThatDontMatchTheirLikedGenresWith(moviesThatAreSimilar: [Movie]) -> [Movie] {
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
                    if similarIDS >= 3 {
                        moviesToReturn.append(movie)
                        continue
                    }
                }
            }
        }
        
        return moviesThatAreSimilar
    }
    
    /// This finds movies that are similar and returns and array of movies
    private func initalizeTheMoviesThatAreSimilarWith(_ similarMovies: [String], movies: [Movie]) -> [Movie] {
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
