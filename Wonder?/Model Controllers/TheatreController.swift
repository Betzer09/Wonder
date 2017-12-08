//
//  TheatreController.swift
//  Wonder?
//
//  Created by Austin Betzer on 12/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation

class TheatreController {
    static let shared = TheatreController()
    
    var theaterMovies: [TheatreMovies.TheaterMovie] = []
    
    /// This should only be used for testing.
    func fetchTheaterMovies(completion: @escaping ([TheatreMovies.TheaterMovie]?) -> Void) {
        
        let jsonFilePath = Bundle.main.path(forResource: "TheatreMovies", ofType: "json")
        var filedata: Data?
        
        guard let filePath = jsonFilePath else {return}
        filedata = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        
        
        guard let data = filedata else {print("Error with Movie Genre Data in \(#file) and function: \(#function)")
            completion([])
            return
        }
        
        
        let jsonDecoder = JSONDecoder()
        
        do {
            let result = try jsonDecoder.decode(TheatreMovies.self, from: data)
            self.theaterMovies = result.movies
            completion(result.movies)
            
        } catch let e {
            print(e)
        }
        
    }
    
    /// This should be used in the real app
    func fetchTheaterMoviesFromAPI(completion: @escaping ([TheatreMovies]) -> Void) {
        let baseURL = URL(string: "http://data.tmsapi.com/v1.1/movies/showings")
        //http://data.tmsapi.com/v1.1/movies/showings?startDate=2017-12-07&zip=84111&api_key=f63btc28rntf3tvv2j4tvvtp
        
        guard let unwrappedURL = baseURL else {print("Bad Movie Theater Showtimes URL in file \(#file) and function: \(#function)"); return}
        
        var urlComponents = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: true)
        
        // TODO: -  Fix these parameteres to have a unique zip and corret formatted date
        let parameters = ["api_key": "f63btc28rntf3tvv2j4tvvtp", "zip": "84111", "startDate": "\(Date())"]
        urlComponents?.queryItems = parameters.flatMap( { URLQueryItem(name: $0.key, value: $0.value)})
        
        guard let url = urlComponents?.url else {NSLog("Bad url components \(#function)"); return}
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            if let error = error  {
                print("Error fetching Movie Theater Showtimes in file: \(#file) and function: \(#function) because of error: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = data else {print("Error with movie theater data in file: \(#file) and function \(#function)"); return}
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let jsonArray = try jsonDecoder.decode(TheatreMovies.self, from: data)
                self.theaterMovies = jsonArray.movies
                
            } catch let error {
                print("\(error.localizedDescription)")
            }
            
        }
        
    }
    
}




















