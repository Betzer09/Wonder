//
//  QuestionController.swift
//  Wonder?
//
//  Created by Austin Betzer on 11/22/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation

class QuestionController {
    
    // MARK: - Properties
    static let shared = QuestionController()
    var questions: [Question] = []
    
    // MARK: - Methods
    var question1 = Question(question: "Are you by yourself?")
    var question2 = Question(question: "Have you had a good day?")
    var question3 = Question(question: "Have you been home all day?")
    var questoin4 = Question(question: "Do you like sports?")
    
    
    
}
