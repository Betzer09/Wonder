//
//  Movie.swift
//  Wonder?
//
//  Created by Austin Betzer on 11/20/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import UIKit

struct Movie: Decodable, Equatable {
    
    static func ==(lhs: Movie, rhs: Movie) -> Bool {
        return lhs.title == rhs.title && lhs.releaseDate == rhs.releaseDate && lhs.genreIDS == rhs.genreIDS && lhs.overview == rhs.overview && lhs.voteAverage == rhs.voteAverage
    }
    
    // MARK: - Properties
    let title: String
    var posterPath: String? = ""
    let genreIDS: [Int]
    let overview: String
    let voteAverage: Double
    let adult: Bool
    let releaseDate: String?
    let video: Bool
    let id: Int
    var isLiked: Bool? = nil
    var imageData: Data? = nil
    var isSimilarTo: String? = ""
    var backdropPath: String? = ""
    
    enum CodingKeys: String, CodingKey {
        case title
        case overview
        case video
        case adult
        case id
        case genreIDS = "genre_ids"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"

    }

}

struct Movies: Decodable {
    var results: [Movie]
}

















