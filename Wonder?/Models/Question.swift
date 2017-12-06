//
//  Question.swift
//  Wonder?
//
//  Created by Austin Betzer on 11/22/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation

class Question: Equatable {
    
    static func ==(lhs: Question, rhs: Question) -> Bool {
        return lhs.text == rhs.text
    }
    
    let text: String
    var answer: Bool?
    
    init(question: String, answer: Bool = false) {
        self.text = question
        self.answer = answer
    }
    
}
