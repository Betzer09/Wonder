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
    let posterPath: String
    let genreIDS: [Int]
    let overview: String
    let voteAverage: Double
    let adult: Bool
    let releaseDate: String
    let video: Bool
    
    enum CodingKeys: String, CodingKey {
        case title
        case overview
        case video
        case adult
        case genreIDS = "genre_ids"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case posterPath = "poster_path"
        
    }
    
//    struct GenreIDS: Decodable {
//        let id: Int
//    }
    
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        self.title = try valueContainer.decode(String.self, forKey: .title)
        self.overview = try valueContainer.decode(String.self, forKey: .overview)
        self.video = try valueContainer.decode(Bool.self, forKey: .video)
        self.adult = try valueContainer.decode(Bool.self, forKey: .adult)
        self.releaseDate = try valueContainer.decode(String.self, forKey: .releaseDate)
        self.voteAverage = try valueContainer.decode(Double.self, forKey: .voteAverage)
        self.posterPath = try valueContainer.decode(String.self, forKey: .posterPath)
        
        let IDS = try valueContainer.decode([Int].self, forKey: .genreIDS)
        self.genreIDS = IDS.flatMap({ $0 })
        
    }
    
}

struct Movies: Decodable {
    var results: [Movie]
}











