//
//  Movie.swift
//  Wonder?
//
//  Created by Austin Betzer on 11/20/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import UIKit

class Movie: Decodable, Equatable {
    
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
    let video: Bool
    let id: Int
    var isLiked: Bool? = nil
    var imageData: Data? = nil
    var backdropPath: String? = ""
    var similarMovie: Movie? = nil
    
    var releaseDate: String
    
    var formattedReleaseDate: String {
        guard let convertedStringDate = returnFormattedDateForMovieLabel(string: self.releaseDate),
            let finalDate = returnFormattedDateFrom2(date: convertedStringDate) else { return " "}
        return finalDate
    }
    
    init(title: String, posterPath: String, genresIDS: [Int], overview: String, voteAverage: Double, adult: Bool, releaseDate: String, video: Bool, id: Int, isLiked: Bool, imageData: Data, backdropPath: String, similarMovie: Movie? = nil ) {
        
        self.title = title
        self.posterPath = posterPath
        self.genreIDS = genresIDS
        self.overview = overview
        self.voteAverage = voteAverage
        self.adult = adult
        self.video = video
        self.id = id
        self.isLiked = isLiked
        self.imageData = imageData
        self.backdropPath = backdropPath
        self.similarMovie = similarMovie
        self.releaseDate = releaseDate
    
    }
    
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
