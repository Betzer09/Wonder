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
    Question(question: "Are you with someone special? 1"),
    Question(question: "Are you/everyone exhausted? 2"),
    Question(question: "Ae you looking to get out of the house? 3"),
    ]
    
    
    /// Takes in a question and will toggle it to either yes or no
    func toggleStatusForQuestion(question: Question, isLiked: Bool) {
        question.answer = isLiked
    }
    
    /// This will return whether or not the user wants to go out.
    func doesTheUserWantToGoOut() -> Bool {
        if questions[2].answer == true {
            return true
        }
        return false
    }
    
}
