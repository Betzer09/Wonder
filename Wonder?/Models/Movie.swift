//
//  Movie.swift
//  Wonder?
//
//  Created by Austin Betzer on 11/20/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation

struct Movie: Decodable {
    
    // MARK: - Properties
    let title: String
    let id: Int
    let posterPath: String
    let genresIDS: [Int]
    let overview: String
    let voteAverage: Double
    let adult: Bool
    let releaseDate: String
    let video: Bool
    
    enum CodingKeys: String, CodingKey {
        case title
        case id
        case overview
        case video
        case adult
        case releaseDate = "release_date"
        case genresIDS = "genre_ids"
        case voteAverage = "vote_average"
        case posterPath = "poster_path"
        
    }
}

struct Movies: Decodable {
    var results: [Movie]
}
