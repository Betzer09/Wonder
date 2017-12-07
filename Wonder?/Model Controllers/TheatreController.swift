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
    func fetchTheaterMovies() {
        
        let jsonFilePath = Bundle.main.path(forResource: "TheatreMovies", ofType: "json")
        var filedata: Data?
        
        guard let filePath = jsonFilePath else {return}
        filedata = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        
        
        guard let data = filedata else {print("Error with Movie Genre Data in \(#file) and function: \(#function)"); return}
        
        
        let jsonDecoder = JSONDecoder()
        
        do {
            let jsonArray = try jsonDecoder.decode(TheatreMovies.self, from: data)
           self.theaterMovies = jsonArray.movies
            
        } catch let e {
            print(e)
        }
        
    }
}
