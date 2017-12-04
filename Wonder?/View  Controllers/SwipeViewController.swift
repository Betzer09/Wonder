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
    @IBOutlet weak var topCardView: UIView!
    @IBOutlet weak var bottomCardView: UIView!
    @IBOutlet weak var thumbImageView: UIImageView!
    //    @IBOutlet weak var genreNameLabel: UILabel!
    //    @IBOutlet weak var moviePosterImageView: UIImageView!
    
    // MARK: - Properties
    var genreCount: Int?
    var genreCounter = 1
    var availableGenres: [Genre] = []
    var likedGenresCount: Int?
    var discoveredMovies: [Movie] = []
    
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        // Watches to see if a genre has been updated
        NotificationCenter.default.addObserver(self, selector: #selector(refetchGenres), name: GenresController.genreWasUpatedNotifaction, object: nil)
        
    }
    
    // MARK: - SetUp UI
    func configureView() {
        genreCount = GenresController.shared.genres.count
        likedGenresCount = GenresController.shared.likedGenres.count
        availableGenres = GenresController.shared.genres
        discoveredMovies = MovieController.shared.discoveredMoviesBasedOnGenres
        //        genreNameLabel.text = "\(availableGenres[0].name)"
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
        } else {
            // The card is going left
            thumbImageView.image = #imageLiteral(resourceName: "thumbsDown")
            
        }
        
        thumbImageView.alpha = abs(xFromCenter) / view.center.x
        card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        card.transform = CGAffineTransform(rotationAngle: (xFromCenter / view.frame.width) * 0.61).scaledBy(x: scale, y: scale)
        
        //        guard let indexOfGenre = GenresController.shared.genres.index(where: { $0.name == genreNameLabel.text }) else {
        //            NSLog("Error finding Genre in file: \(#file)")
        //            return
        //        }
        //        let genreToModify = GenresController.shared.genres[indexOfGenre]
        //        let genreToModify = GenresController.shared.genres[0]
        
        if sender.state == .ended {
            // Figure out if they liked three genres
            // Once they have Liked three genres fetch those movies
            // Let them swipe through movies based on their genres
            guard let likedGenresCount = likedGenresCount else {print("Broken likedGenreCount");return}
            
            if likedGenresCount >= 3 {
                // Fetch those movies
                let ids = GenresController.shared.likedGenres.flatMap({ $0.id })
                MovieController.shared.fetchMoviesBasedOnGenresWith(ids: ids, pageCount: 1, completion: { (_) in})
                
                //                let movie = discoveredMovies[0]
                //                MovieController.shared.fetchImageWith(endpoint: movie.posterPath, completion: { (image) in
                //                    DispatchQueue.main.async {
                //                        self.moviePosterImageView.image = image
                //                    }
                //                    self.moviePosterImageView.alpha = 1
                //                })
                
            }
            
            
            if card.center.x < 75 {
                // Move off to the left side
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: card.center.x - 200, y: card.center.y + 75)
                    card.alpha = 0
                }, completion: { (_) in
                    self.setBottomCardToTop(card)
                })
                
                
                //                if likedGenresCount < 3 {
                //                GenresController.shared.toggleIsLikedStatusFor(genre: genreToModify, isLiked: false)
                //                }
                
            } else if card.center.x > (view.frame.width - 75) {
                // Move off to the right side
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 75)
                    card.alpha = 0
                }, completion: { (_) in
                    self.setBottomCardToTop(card)
                })
                
                
                //                if likedGenresCount < 3 {
                //                GenresController.shared.toggleIsLikedStatusFor(genre: genreToModify, isLiked: true)
                //                }
            }
        }
        
    }
    
    
    // MARK: - Methods
    
    @objc func refetchGenres() {
        availableGenres = GenresController.shared.genres
        likedGenresCount = GenresController.shared.likedGenres.count
    }
    
    func setBottomCardToTop(_ card: UIView) {
        card.center = view.center
        thumbImageView.alpha = 0
        card.transform = .identity
        card.alpha = 1
        
    }
    
    /// This repositions the card back to the center
    func resetCard() {
        UIView.animate(withDuration: 0.2, animations: {
            self.topCardView.center = self.view.center
            self.thumbImageView.alpha = 0
            self.topCardView.alpha = 1
            self.topCardView.transform = .identity
        })
        if genreCounter >= genreCount! {
            GenresController.shared.filterUnlikedAndLikedGenres()
        } else {
            //            genreNameLabel.text = "\(GenresController.shared.genres[genreCounter].name)"
            //            genreCounter += 1
        }
        
    }
    
    
}
