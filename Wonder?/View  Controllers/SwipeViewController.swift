//
//  SwipeViewController.swift
//  Wonder?
//
//  Created by Austin Betzer on 11/21/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class SwipeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var genreNameLabel: UILabel!
    
    // MARK: - Properties
    var genreCount: Int?
    var genreCounter = 1
    var availableGenres: [Genre] = []
    var likedGenres: [Genre] = []
    var unlikedGenres: [Genre] = []
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        // Watches to see if a genre has been updated
        NotificationCenter.default.addObserver(self, selector: #selector(refetchGenres), name: GenresController.genreWasUpatedNotifaction, object: nil)
        
    }
    
    // MARK: - SetUp UI
    func configureView() {
        genreCount = GenresController.shared.genries.count
        availableGenres = GenresController.shared.genries
        genreNameLabel.text = "\(availableGenres[0].name)"
    }

    // MARK: - Actions
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        guard let card = sender.view else {return }
        let point = sender.translation(in: view)
        let xFromCenter = card.center.x - view.center.x
        let scale = min(100/abs(xFromCenter), 1)
        
        if xFromCenter > 0 {
            // The card is going right
            thumbImageView.image = #imageLiteral(resourceName: "thumbsUp")
            thumbImageView.tintColor = UIColor.green
        } else {
            // The card is going left
            thumbImageView.image = #imageLiteral(resourceName: "thumbsDown")
            thumbImageView.tintColor = UIColor.red
            
        }
        
        thumbImageView.alpha = abs(xFromCenter) / view.center.x
        card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        card.transform = CGAffineTransform(rotationAngle: (xFromCenter / view.frame.width) * 0.61).scaledBy(x: scale, y: scale)
        
        guard let indexOfGenre = GenresController.shared.genries.index(where: { $0.name == genreNameLabel.text }) else {
            NSLog("Error finding Genre in file: \(#file)")
            return
        }
        let genreToModify = GenresController.shared.genries[indexOfGenre]
        
        if sender.state == .ended {
            
            if card.center.x < 75 {
                // Move off to the left side
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: card.center.x - 200, y: card.center.y + 75)
                    card.alpha = 0
                })
                GenresController.shared.toggleIsLikedStatusFor(genre: genreToModify, isLiked: false)
            } else if card.center.x > (view.frame.width - 75) {
                // Move off to the right side
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 75)
                    card.alpha = 0
                })
                GenresController.shared.toggleIsLikedStatusFor(genre: genreToModify, isLiked: true)
            }
            resetCard()
        }
        
    }
    
    @IBAction func reset(_ sender: Any) {
        resetCard()
    }
    
    // MARK: - Methods
    
    @objc func refetchGenres() {
        availableGenres = GenresController.shared.genries
    }
    
    func createCards() {
        
        guard let genreCount = genreCount else {return}
        for _ in 0...genreCount {
            // We want to create 19 views and stack them on top of each other
            let newView = cardView
            view.addSubview(newView!)
        }
    }
    
    func resetCard() {
        UIView.animate(withDuration: 0.2, animations: {
            self.cardView.center = self.view.center
            self.thumbImageView.alpha = 0
            self.cardView.alpha = 1
            self.cardView.transform = .identity
        })
        
        if genreCounter >= genreCount! {
            likedGenres = availableGenres.filter( { $0.isLiked == true  } )
            unlikedGenres = availableGenres.filter({ $0.isLiked == false })
        } else {
            genreNameLabel.text = "\(GenresController.shared.genries[genreCounter].name)"
            genreCounter += 1
        }

    }
    
    
}




















