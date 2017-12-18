//
//  MovieTrailor.swift
//  Wonder?
//
//  Created by Austin Betzer on 12/14/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation

struct MovieTrailers: Decodable {
    
    let results: [MovieTrailor]
    
//    init(from decoder: Decoder) throws {
//        var toplevelContainer = try decoder.unkeyedContainer()
//        
//        var trailors: [MovieTrailor] = []
//        
//        while !toplevelContainer.isAtEnd {
//            let trailor = try toplevelContainer.decode(MovieTrailor.self)
//            trailors.append(trailor)
//        }
//        
//        self.results = trailors
//    }
    
    struct MovieTrailor: Decodable {
        
        // MARK: - Properties
        let id: String
        let key: String
        let name: String
        let type: String
        var movieID: Int? = nil
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case key
            case type
        }
    }
    
}
