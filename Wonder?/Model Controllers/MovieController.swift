//
//  MovieController.swift
//  Wonder?
//
//  Created by Austin Betzer on 11/21/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class MovieController {
//    // MARK: - Notifcations
//    static let similarMoviesToDisplayToTheUserWasUpdated = Notification.Name("similarMoviesToDisplayToTheUserWasUpdated")
//    static let recommendedTheaterMoviesToDisplayToTheUserWasUpdated = Notification.Name("recommendedTheaterMoviesToDisplayToTheUserWasUpdated")
    
    // MARK: - Properties
    static let shared = MovieController()
    
    /// This is an array full of movies the user should watch
    var discoveredMoviesBasedOnGenres: [Movie] = []
    
    var finalMoviesResluts: [Movie] = []
    
    
    // MARK: - Fetch Functions
    
    /// Fetches recommended movies from the movieDB and fills the recommendedMovies array
    func fetchRecommendedMoviesFromTheMovieDBWith(id: Int, completion: @escaping (Movie?) -> Void) {
        
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
            
            completion(movies.results.first)
            
            }.resume()
        
    }
    
    //https://api.themoviedb.org/3/discover/movie?api_key=c366b28fa7f90e98f633846b3704570c&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_genres=28
    /// fetches movies based on genres with the MovieDB Discover call and fills the discoveredMoviesBasedOnGenresArray
    func fetchMoviesBasedOnGenresWith(ids: [Int], pageCount: Int, completion: @escaping ([Movie]) -> Void) {
        
        let discoverMoviesBaseURL = URL(string: "https://api.themoviedb.org/3/discover/movie")
        
        guard let unwrappedURL = discoverMoviesBaseURL else {NSLog("Bad Discover URL \(#file)"); return}
        
        var urlComponents = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: true)
        var stringOfIDs = ""
        
        for id in ids {
            stringOfIDs.append("\(id),")
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
                self.fetchMoviesThatAreSimilarWith(moviesThatMatchTheirLikedGenres: movies.results, completion: { (isComplete) in
                    guard !isComplete else {return}
                    completion(movies.results)
                })
            } catch let error {
                print("Error initalzing discovered movies in function \(#file) and function: \(#function) becuase of error: \(error.localizedDescription)")
            }
            }.resume()

        
        
    }
    
    /// Fetches the images from the movie DB
    func fetchImageWith(endpoint: String, movie: Movie, completion: @escaping (_ isComplete: Bool) -> Void = { _ in }) {
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
            movie.imageData = imageData
            completion(true)
            
            }.resume()
    }
    
    //https://api.themoviedb.org/3/movie/562/similar?api_key=c366b28fa7f90e98f633846b3704570c&language=en-US&page=1
    ///Fetces movies that are similar to the given movie id and fills the similarMoviesToDisplayToTheUser Array
    private func fetchMoviesThatAreSimilarWith(movie: Movie, completion: @escaping ([Movie]) -> Void = {_ in}, completionHandler: @escaping (_ isComplete: Bool) -> Void)  {
        
        let customURL = "https://api.themoviedb.org/3/movie/\(movie.id)/similar"
        guard let baseURL = URL(string: customURL) else { completion([]); completionHandler(false); NSLog("Bad \"Similar Movie\" URL in function: \(#function)"); return}
        
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        let parameters = ["api_key": "c366b28fa7f90e98f633846b3704570c", "language": "en-US" ]
        
        urlComponents?.queryItems = parameters.flatMap( { URLQueryItem(name: $0.key , value: $0.value)})
        
        guard let url = urlComponents?.url else { completion([]); completionHandler(false); NSLog("Bad url components in function: \(#function)"); return}
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            if let error = error {
                print("Error fetching movies that are \"Similar\" to the movie from the MovieDB in file: \(#file) and function: \(#function) because of error: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = data else { completion([]); completionHandler(false); print("Error with \"Similar Movie\"  MovieDB data in file \(#file) and function:\(#function) "); return}
            
            
            do {
                let movies = try JSONDecoder().decode(Movies.self, from: data)
                
                // Get the first movie that comes back and assign that movie to the owners similar movie
                guard let similarMovie = movies.results.first, let path = similarMovie.posterPath else {return}
                self.fetchImageWith(endpoint: path, movie: similarMovie, completion: { (isComplete) in
                    guard !isComplete else {return}
                    movie.similarMovie = similarMovie
                    
                    // Add the movie to the array
                    self.discoveredMoviesBasedOnGenres.append(movie)
                    completion(movies.results)
                    completionHandler(true)
                })
            } catch let error {
                NSLog("Error initalzing \"Similar\" movie with URL \(url) in function \(#file) and function: \(#function) becuase of error: \(error.localizedDescription)")
                completionHandler(false)
                completion([]);
            }
            
            }.resume()
        
    }
    
    //https://api.themoviedb.org/3/movie/now_playing?api_key=c366b28fa7f90e98f633846b3704570c&language=en-US&page=3
    /// This returns movies that are currently playing according to the movieDB and fills the nowPlayingMovies Array
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
                completion(movies.results)
            } catch let error {
                print("Error initalzing Now Playing movies in function \(#file) and function: \(#function) becuase of error: \(error.localizedDescription)")
                completion([])
            }
            
            }.resume()
        
        
    }
    
    /// Fetches recommended movies based on the users answers
    func calulateWhatTheUserWantsToSee(completion: @escaping (_ isComplete: Bool) -> Void) {
        // If the answer is true they want to go the the movie theaters
        let answer = QuestionController.shared.doesTheUserWantToGoOut()
        print(answer)
        // Fetch movies in theaters
        if answer {
            
            DispatchQueue.main.async {
                // Fetch theaterMovies that are in theaters if this fails just fetch movies that are in theaters using the movieDB
                TheatreController.shared.fetchTheaterMovies(completion: { (theaterMovies) in
                    if theaterMovies.isEmpty {
                        // Fetch movies that are now playing useing the movieDB
                        
                        MovieController.shared.fetchMoviesThatAreNowPlaying(page: 1, completion: { (movies) in
                            print("You need to set up a reponce in case you run out of API calls")
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
            }
        } else {
            
            // Fetch movies from discover with all of their genres that they picked
            DispatchQueue.main.async {
                let likedGenres = GenresController.shared.likedMovieGenres.map({ $0.id })
                self.fetchMoviesBasedOnGenresWith(ids: likedGenres, pageCount: 1, completion: { (movies) in
                    if movies.isEmpty {return}
                    self.discoveredMoviesBasedOnGenres += movies
                })
            }
            
            // Take the "liked Movies" and grab their ID
            // Use the array of IDS and Start from the top and fetch recommeded movies based on those id
            // If they don't like a movie that's similar filter out the recommended movie
            self.fetchMoviesThatAreSimilarWith(moviesThatMatchTheirLikedGenres: self.discoveredMoviesBasedOnGenres, completion: { (isComplete) in
                if isComplete {
                    completion(true)
                }
            })
        }
    }
    
    var groupCount = 0 {
        didSet {
            print("Group count: \(groupCount)")
        }
    }
    
    // MARK: - Functions
    
    func toggleSimilarMoviesStatisFor(movie: Movie, with isLiked: Bool) -> Movie {
        movie.isLiked = isLiked
        
        return movie
    }
    
    /// Fetches Movies that are similar using the movie ID and returns an array of Movies as well as assigns the similar movie to it's corrisponding recommended movie
    func fetchMoviesThatAreSimilarWith(moviesThatMatchTheirLikedGenres: [Movie], completion: @escaping (_ isComplete: Bool) -> Void) {
        
        let fetchSimilarMoviesGroup = DispatchGroup()
        
        // For every movie fetch a similar movie
        for movie in moviesThatMatchTheirLikedGenres {
            fetchSimilarMoviesGroup.enter()
            self.groupCount += 1
            print("Group entered")
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
                    self.fetchMoviesThatAreSimilarWith(movie: movie, completionHandler: { (isFinished) in
                        guard !isFinished else {return}
                    })
                })
            }
        }
        
        fetchSimilarMoviesGroup.notify(queue: DispatchQueue.main) {
            completion(true)
        }
    }
    
    /// Filters out recommended movies that the user won't like based on similar movies they don't like. This will be used at the very end before we display them to the user
    func filterOutSimilarMovieWith(movie: Movie) {
        guard let isLiked = movie.isLiked else {return}
        var similarMovies = self.discoveredMoviesBasedOnGenres
        
        if !isLiked {
            guard let index = similarMovies.index(of: movie) else {NSLog("Couldn't find movie to filter out \(#function)"); return}
            similarMovies.remove(at: index)
        }
        
//        let theaterMovies = turnMoviesIntoATheaterMoviesWith(movies: similarMovies)
        self.discoveredMoviesBasedOnGenres = similarMovies
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
                let genreCount = movie.genreIDS.count
                
                if movie.genreIDS.contains(id) {
                    similarIDS += 1
                    // Append that movie
                    if Double(similarIDS / genreCount) >= 0.6 {
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
        
        // Fetch Movie on the background thread for everything.
        fetchBackDropImageForMovies()
        return moviesThatAreSimilar
    }
    
    /// This fetches the backDropImage for a given movie
    func fetchBackDropImageForMovies() {
        let group = DispatchGroup()

        let newArrayToReturn: [Movie] = []
        
        for movie in self.discoveredMoviesBasedOnGenres {
            group.enter()
            guard let path = movie.backdropPath else {group.leave(); return}
            self.fetchImageWith(endpoint: path, movie: movie, completion: { (isComplete) in
                group.leave()
            })
        }


        group.notify(queue: DispatchQueue.main) {
            print("Finished Fetching movie images")
            self.discoveredMoviesBasedOnGenres = newArrayToReturn
        }

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
