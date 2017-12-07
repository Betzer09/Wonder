//
//  TheaterMovie.swift
//  Wonder?
//
//  Created by Austin Betzer on 12/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation

struct TheatreMovies: Decodable {
    
    let movies: [TheaterMovie]
    
    init(from decoder: Decoder) throws {
        
        var topLevelContainer = try decoder.unkeyedContainer()
        
        var movies: [TheaterMovie] = []
        
        while !topLevelContainer.isAtEnd {
            let movie = try topLevelContainer.decode(TheaterMovie.self)
            movies.append(movie)
        }
        self.movies = movies
    }
    
    struct TheaterMovie: Decodable {
        
        // MARK: - Properties
        let title: String
        let releaseDate: String?
        let longDescription: String?
        let topCast: [String]?
        let advisories: [String]?
        let officialUrl: String?     // This can be used to get the trailor
        let showtimes: [TopLevelShowtimes]?
        let ratings: [Ratings]?
        
        struct Ratings: Decodable {
            let code: String        // This is the movie rating
        }
        
        struct TopLevelShowtimes: Decodable {
            let quals: String?
            let dateTime: String    // Time the movie is being played in the theater
            let barg: Bool          // This is a bool that shows if it is matinee princing
            let ticketURI: String?
            let theatre: Theatre
            
            struct Theatre: Decodable {
                let name: String    // Theater name
            }
        }
        enum TopLevelCodingKeys: String, CodingKey {
            case title
            case releaseDate
            case longDescription
            case topCast
            case advisories
            case officialUrl
            case showtimes
            case ratings
        }
        
        enum TheaterCodingKeys: String, CodingKey {
            case dateTime
            case quals
            case barg
            case ticketURI
        }
        
    }
    
}






















