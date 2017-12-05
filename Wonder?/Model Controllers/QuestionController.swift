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
    var questions: [Question] = [
    Question(question: "Are you by yourself?"),
    Question(question: "Have you had a good day?"),
    Question(question: "Have you been home all day?"),
    Question(question: "Do you like sports?")
    ]
}
