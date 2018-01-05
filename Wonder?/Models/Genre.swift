//
//  Genre.swift
//  Wonder?
//
//  Created by Austin Betzer on 11/21/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation


class Genre: Decodable, Equatable {
    
    static func ==(lhs: Genre, rhs: Genre) -> Bool {
        return lhs.name == rhs.name && lhs.id == rhs.id
    }
    
    
    let name: String
    let id: Int
    var genreImageData: Data?
    var isLiked: Bool?
    
    init(name: String, id: Int, genreImageData: Data, isLiked: Bool) {
        self.name = name
        self.id = id
        self.genreImageData = genreImageData
        self.isLiked = isLiked
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case id
        case genreImageData
        case isLiked
    }
}

struct Genres: Decodable {
    var genres: [Genre]
}



