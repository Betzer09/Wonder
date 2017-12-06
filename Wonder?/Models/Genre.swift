//
//  Genre.swift
//  Wonder?
//
//  Created by Austin Betzer on 11/21/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import UIKit

struct Genre: Decodable, Equatable {
    
    static func ==(lhs: Genre, rhs: Genre) -> Bool {
        return lhs.name == rhs.name && lhs.id == rhs.id
    }
    
    let name: String
    let id: Int
    var genreImage: Data?
    var isLiked: Bool?
    
    enum CodingKeys: String, CodingKey {
        case name
        case id
        case genreImage
        case isLiked
    }
}

struct Genres: Decodable {
    var genres: [Genre]
}



