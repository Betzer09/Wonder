//
//  Question.swift
//  Wonder?
//
//  Created by Austin Betzer on 11/22/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation

class Question {
    let question: String
    var answer: Bool?
    
    init(question: String, answer: Bool = false) {
        self.question = question
        self.answer = answer
    }
    
}
