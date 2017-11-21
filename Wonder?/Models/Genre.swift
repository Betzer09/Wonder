//
//  Genre.swift
//  Wonder?
//
//  Created by Austin Betzer on 11/21/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation

struct Genre: Decodable {
    let name: String
    let id: Int
    
    enum CodingKeys: String, CodingKey {
        case name
        case id
    }
}

struct Genres: Decodable {
    var genres: [Genre]
}
